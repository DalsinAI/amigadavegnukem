/* A Shell gives 4 KB of stack; libnix's startup swaps to this much instead.
 * Dave Gnukem keeps 8 KB message buffers on the stack (sys_error.cpp),
 * and its menus and the level editor nest.
 * The AmiCradle Team. GPL 2 or MIT, like Dave Gnukem. */
unsigned long __stack = 256 * 1024;
static const char version[] __attribute__((used)) = "$VER: DaveGnukem 1.0.3 Amiga (05.11.2026)";
