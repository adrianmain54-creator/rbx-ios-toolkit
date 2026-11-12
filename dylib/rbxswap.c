#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdint.h>

#define PORT 53847
#define BUFSZ 16384
#define PATHMAX_ 1024

static char g_assets_dir[PATHMAX_];
static char g_log_path[PATHMAX_];
static int g_mod_enabled = 0; // DEFAULT OFF

const char* rbxswap_assets_dir(void) { return g_assets_dir; }
const char* rbxswap_misses_log(void) { return g_log_path; }
void set_rbxswap_enabled(int en) { g_mod_enabled = en; }
int get_rbxswap_enabled(void) { return g_mod_enabled; }

static void resolve_dirs(void) {
    const char* home = getenv("HOME");
    if (!home) return;
    snprintf(g_assets_dir, sizeof(g_assets_dir), "%s/Documents/rbxswap_assets", home);
    snprintf(g_log_path, sizeof(g_log_path), "%s/Documents/rbxswap_misses.log", home);
    mkdir(g_assets_dir, 0755);
}

static const char* mime_for(const char* ext) {
    if (!strcasecmp(ext, "png"))  return "image/png";
    if (!strcasecmp(ext, "jpg"))  return "image/jpeg";
    if (!strcasecmp(ext, "mp4"))  return "video/mp4";
    return "application/octet-stream";
}

static int serve_file(int fd, const char* id) {
    static const char* exts[] = {"png","jpg","mp4","bin", NULL};
    for (int i = 0; exts[i]; i++) {
        char full[PATHMAX_*2];
        snprintf(full, sizeof(full), "%s/%s.%s", g_assets_dir, id, exts[i]);
        FILE* f = fopen(full, "rb");
        if (!f) continue;
        fseek(f, 0, SEEK_END); long n = ftell(f); fseek(f, 0, SEEK_SET);
        if (n <= 0) { fclose(f); continue; }
        char* buf = malloc((size_t)n);
        if (fread(buf, 1, (size_t)n, f) == (size_t)n) {
            char hdr[512];
            int hl = snprintf(hdr, sizeof(hdr), "HTTP/1.1 200 OK\r\nContent-Type: %s\r\nContent-Length: %ld\r\nConnection: close\r\n\r\n", mime_for(exts[i]), n);
            write(fd, hdr, hl); write(fd, buf, n);
        }
        free(buf); fclose(f); return 1;
    }
    return 0;
}

static void* handle_conn(void* arg) {
    int fd = (int)(intptr_t)arg;
    char buf[BUFSZ]; ssize_t n = recv(fd, buf, sizeof(buf)-1, 0);
    if (n <= 0) { close(fd); return NULL; } buf[n] = 0;
    char path[BUFSZ] = {0}; sscanf(buf, "GET %16383s", path);
    char id[64] = {0}; char* q = strchr(path, '?');
    if (q) { char* p = strstr(q, "id="); if (p) { p += 3; int i = 0; while (*p && *p != '&' && i < 63) id[i++] = *p++; id[i] = 0; } }
    
    if (g_mod_enabled && id[0] && serve_file(fd, id)) { close(fd); return NULL; }
    if (g_mod_enabled && id[0]) { FILE* lf = fopen(g_log_path, "a"); if (lf) { fprintf(lf, "%s\n", id); fclose(lf); } }
    
    char loc[BUFSZ]; int ll = snprintf(loc, sizeof(loc), "HTTP/1.1 302 Found\r\nLocation: https://assetdelivery.roblox.com%s\r\nConnection: close\r\n\r\n", path);
    write(fd, loc, ll); close(fd); return NULL;
}

static void* accept_loop(void* arg) {
    int s = (int)(intptr_t)arg;
    for (;;) { int c = accept(s, NULL, NULL); if (c < 0) continue; pthread_t t; if (pthread_create(&t, NULL, handle_conn, (void*)(intptr_t)c) == 0) pthread_detach(t); }
    return NULL;
}

__attribute__((constructor)) static void init(void) {
    resolve_dirs();
    int s = socket(AF_INET, SOCK_STREAM, 0); int yes = 1; setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
    struct sockaddr_in a; memset(&a, 0, sizeof(a)); a.sin_family = AF_INET; a.sin_port = htons(PORT); a.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    if (bind(s, (struct sockaddr*)&a, sizeof(a)) >= 0 && listen(s, 32) >= 0) { pthread_t t; if (pthread_create(&t, NULL, accept_loop, (void*)(intptr_t)s) == 0) pthread_detach(t); }
}
