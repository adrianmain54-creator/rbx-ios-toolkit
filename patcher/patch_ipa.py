#!/usr/bin/env python3
import sys, os, zipfile, tempfile, shutil, struct, json

TARGET      = b"https://assetdelivery.roblox.com"
REPLACEMENT = b"http://127.0.0.1:53847".ljust(31, b"\x00")
DYLIB_PATH  = b"@executable_path/Frameworks/RBXSwapKit.framework/RBXSwapKit"
HERE        = os.path.dirname(os.path.abspath(__file__))
FFLAGS_SRC  = os.path.join(HERE, "..", "fflags", "ClientAppSettings.json")
FW_SRC      = os.path.join(HERE, "..", "dylib", "RBXSwapKit.framework")
BUNDLE      = "Payload/Roblox.app"

MACHO64_LE, MACHO32_LE, FAT_BE, FAT_CIGAM = 0xfeedfacf, 0xfeedface, 0xcafebabe, 0xbebafeca
LC_SEGMENT, LC_SEGMENT_64, LC_LOAD_DYLIB = 0x1, 0x19, 0xC

def looks_macho(p):
    with open(p, "rb") as f: m = f.read(4)
    return len(m) == 4 and (struct.unpack("<I", m)[0] in (MACHO64_LE, MACHO32_LE) or struct.unpack(">I", m)[0] in (FAT_BE, FAT_CIGAM))

def add_load_dylib(path, dylib_path):
    with open(path, "rb") as f: data = bytearray(f.read())
    magic = struct.unpack_from("<I", data, 0)[0]
    if magic not in (MACHO64_LE, MACHO32_LE): raise RuntimeError("Not a thin Mach-O")
    is64 = magic == MACHO64_LE; hdr = 32 if is64 else 28
    ncmds = struct.unpack_from("<I", data, 16)[0]; sizeofcmds = struct.unpack_from("<I", data, 20)[0]
    lc_end = hdr + sizeofcmds
    min_sec = None; off = hdr
    for _ in range(ncmds):
        cmd, sz = struct.unpack_from("<II", data, off)
        if cmd in (LC_SEGMENT_64, LC_SEGMENT):
            nsects = struct.unpack_from("<I", data, off+(64 if is64 else 48))[0]
            s_off = off + (72 if is64 else 56); s_stride = 80 if is64 else 68; foff = 48 if is64 else 40
            for i in range(nsects):
                so = struct.unpack_from("<I", data, s_off + i*s_stride + foff)[0]
                if so and (min_sec is None or so < min_sec): min_sec = so
        off += sz
    if min_sec is None: raise RuntimeError("No sections")
    slack = min_sec - lc_end
    name_len = len(dylib_path) + 1; lc_size = (8 + 16 + name_len + 7) & ~7
    if lc_size > slack: raise RuntimeError(f"Not enough slack (need {lc_size}, have {slack})")
    lc = bytearray(lc_size); struct.pack_into("<I", lc, 0, LC_LOAD_DYLIB); struct.pack_into("<I", lc, 4, lc_size); struct.pack_into("<I", lc, 8, 24); struct.pack_into("<I", lc, 16, 0x10000); struct.pack_into("<I", lc, 20, 0x10000)
    lc[24:24+len(dylib_path)] = dylib_path
    data[lc_end:lc_end+lc_size] = lc; struct.pack_into("<I", data, 16, ncmds+1); struct.pack_into("<I", data, 20, sizeofcmds+lc_size)
    with open(path, "wb") as f: f.write(data)

def main():
    in_ipa, out_ipa = sys.argv[1], sys.argv[2]
    work = tempfile.mkdtemp()
    try:
        with zipfile.ZipFile(in_ipa) as z: z.extractall(work)
        exe = os.path.join(work, BUNDLE, "Roblox")
        if not os.path.exists(exe): raise RuntimeError("Roblox binary missing")
        
        dst_fw = os.path.join(work, BUNDLE, "Frameworks", "RBXSwapKit.framework")
        if os.path.exists(dst_fw): shutil.rmtree(dst_fw)
        shutil.copytree(FW_SRC, dst_fw)
        add_load_dylib(exe, DYLIB_PATH)
        
        with open(FFLAGS_SRC, "rb") as f: fb = f.read(); json.loads(fb.decode())
        for t in (os.path.join(work, BUNDLE, "ClientAppSettings.json"), os.path.join(work, BUNDLE, "Library", "Application Support", "ClientAppSettings.json")):
            os.makedirs(os.path.dirname(t), exist_ok=True); open(t, "wb").write(fb)
            
        with open(exe, "rb") as f: d = f.read()
        if TARGET in d: open(exe, "wb").write(d.replace(TARGET, REPLACEMENT))
        
        if os.path.exists(out_ipa): os.remove(out_ipa)
        with zipfile.ZipFile(out_ipa, "w", zipfile.ZIP_DEFLATED) as z:
            for root, _, files in os.walk(work):
                for fn in files: z.write(os.path.join(root, fn), os.path.relpath(os.path.join(root, fn), work))
    finally: shutil.rmtree(work, ignore_errors=True)

if __name__ == "__main__": main()
