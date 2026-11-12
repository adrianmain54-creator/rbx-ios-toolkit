#!/usr/bin/env python3
"""
patch_ipa.py — bake fflags into a decrypted Roblox IPA.
Usage: python3 patch_ipa.py <in.ipa> <out.ipa>
"""
import sys, os, zipfile, tempfile, shutil, plistlib

HERE       = os.path.dirname(os.path.abspath(__file__))
FFLAGS_SRC = os.path.join(HERE, "..", "fflags", "ClientAppSettings.json")
BUNDLE     = "Payload/Roblox.app"

def main():
    if len(sys.argv) != 3:
        print(__doc__); sys.exit(1)
    in_ipa, out_ipa = sys.argv[1], sys.argv[2]

    if not os.path.exists(FFLAGS_SRC):
        print(f"[!] missing {FFLAGS_SRC}"); sys.exit(2)

    work = tempfile.mkdtemp()
    try:
        with zipfile.ZipFile(in_ipa) as z: z.extractall(work)

        exe = os.path.join(work, BUNDLE, "Roblox")
        if not os.path.exists(exe):
            print(f"[!] {BUNDLE}/Roblox missing"); sys.exit(3)

        with open(FFLAGS_SRC, "rb") as f: fb = f.read()
        plistlib.loads(fb)  # sanity check

        # write JSON to both spots — client reads one, we don't know which
        for t in (os.path.join(work, BUNDLE, "ClientAppSettings.json"),
                  os.path.join(work, BUNDLE, "Library", "Application Support",
                               "ClientAppSettings.json")):
            os.makedirs(os.path.dirname(t), exist_ok=True)
            with open(t, "wb") as f: f.write(fb)
            print(f"[+] fflags -> {os.path.relpath(t, work)}")

        if os.path.exists(out_ipa): os.remove(out_ipa)
        with zipfile.ZipFile(out_ipa, "w", zipfile.ZIP_DEFLATED) as z:
            for root, _, files in os.walk(work):
                for fn in files:
                    full = os.path.join(root, fn)
                    z.write(full, os.path.relpath(full, work))
        print(f"[✓] {out_ipa}")
    finally:
        shutil.rmtree(work, ignore_errors=True)

if __name__ == "__main__":
    main()
