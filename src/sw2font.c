/* SW2FrenchFont.asi - Samurai Warriors 2 (PC), French translation:
 * letter spacing of the accented letters.
 * The French font draws each accented letter in the place of an unused sign
 * (e.g. i-circumflex in the place of '<'), but the game still advances by the
 * width of that sign, so some words got a gap ("trai nee") or letters too close.
 * This plugin gives each of these signs the width of its base letter, in memory
 * only (the table is encrypted in sw2.exe on disk). Loaded by Ultimate ASI Loader. */
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
typedef unsigned char u8;

#define TABLE ((u8 *)0x7133A8)    /* advance width of chars 0x20..0x7F, main text font */
static const u8 ORIG[96] = {
 0x08,0x07,0x0b,0x11,0x0f,0x12,0x13,0x07,0x0b,0x0b,0x0c,0x11,0x07,0x0d,0x07,0x12,
 0x13,0x0c,0x11,0x12,0x12,0x12,0x12,0x12,0x14,0x14,0x08,0x07,0x0d,0x11,0x0d,0x0f,
 0x14,0x13,0x11,0x11,0x11,0x10,0x10,0x12,0x13,0x08,0x0e,0x11,0x0f,0x14,0x13,0x13,
 0x0f,0x13,0x11,0x10,0x11,0x11,0x12,0x14,0x12,0x12,0x11,0x0a,0x14,0x0a,0x0f,0x10,
 0x08,0x0f,0x10,0x0f,0x0f,0x0f,0x0d,0x10,0x10,0x08,0x0a,0x0f,0x09,0x14,0x10,0x0f,
 0x0f,0x0f,0x0b,0x0e,0x0d,0x10,0x10,0x14,0x11,0x10,0x0e,0x12,0x10,0x12,0x10,0x08};
/* sign -> base letter (see ACCENTS in the translation tools) */
static const char MAP[][2] = {
 {'=','e'},{'^','e'},{'_','e'},{'$','a'},{'*','a'},{'>','c'},{'/','o'},{'}','u'},
 {'<','i'},{'`','u'},{'#','E'},{'&','A'},{'\\','C'}};

static char g_logp[MAX_PATH];
static void lg(const char *s) {
    DWORD w; HANDLE h = CreateFileA(g_logp, FILE_APPEND_DATA, FILE_SHARE_READ, 0, OPEN_ALWAYS, 0, 0);
    if (h != INVALID_HANDLE_VALUE) { WriteFile(h, s, lstrlenA(s), &w, 0); CloseHandle(h); }
}
static int same(const u8 *a, const u8 *b, int n) { int i; for (i = 0; i < n; i++) if (a[i] != b[i]) return 0; return 1; }

static DWORD WINAPI worker(LPVOID p) {
    u8 want[96]; int i, done = 0, t;
    (void)p;
    for (i = 0; i < 96; i++) want[i] = ORIG[i];
    for (i = 0; i < (int)(sizeof MAP / sizeof MAP[0]); i++)
        want[MAP[i][0] - 0x20] = ORIG[MAP[i][1] - 0x20];
    for (t = 0; ; t++) {               /* the table is readable once the game is decrypted */
        MEMORY_BASIC_INFORMATION mi;
        if (VirtualQuery(TABLE, &mi, sizeof mi) && mi.State == MEM_COMMIT &&
            !(mi.Protect & (PAGE_NOACCESS | PAGE_GUARD))) {
            if (same(TABLE, ORIG, 96)) {
                DWORD o; VirtualProtect(TABLE, 96, PAGE_READWRITE, &o);
                for (i = 0; i < 96; i++) TABLE[i] = want[i];
                if (!done) lg("Accent widths set.\r\n");
                done = 1;
            } else if (!done && t == 600) {
                lg(same(TABLE, want, 96) ? "Accent widths already set.\r\n"
                                         : "Unexpected font table: nothing changed (other game version?).\r\n");
            }
        }
        Sleep(t < 600 ? 100 : 1000);   /* keep watching: the game may reload the table */
    }
    return 0;
}

BOOL WINAPI DllMain(HINSTANCE h, DWORD r, LPVOID x) {
    (void)x;
    if (r == DLL_PROCESS_ATTACH) {
        char *s; DisableThreadLibraryCalls(h);
        GetModuleFileNameA(h, g_logp, MAX_PATH);
        s = g_logp + lstrlenA(g_logp); while (s > g_logp && s[-1] != '.') s--;
        if (s > g_logp) lstrcpyA(s, "log");
        DeleteFileA(g_logp);
        CreateThread(0, 0, worker, 0, 0, 0);
    }
    return TRUE;
}
