Dave Gnukem for AmigaOS 3.x
===========================

Dave Gnukem 1.0.3 (upstream https://github.com/davidjoffe/dave_gnukem, tag
1.0.3 at commit 88d3c4671443e93c41ccad0ca42974fca745ee9b, the first SDL 2
release; MIT or GPL 2), the retro 2D platform shooter, with its data
(https://github.com/davidjoffe/gnukem_data, tag 1.0.3 at commit
46ccb592857b1cacb66665d45a7d981546ff25a4), for AmigaOS 3.2 on a 68040 or
68060 with an FPU, on OpenGPU's SDL 2.

Status: builds and links; not yet run in the lab.


What you need
-------------

- AmigaOS 3.2 (or 3.2.3 with GFOpenUp), a 68040/68060 with an FPU.
- An RTG screen: the game draws 320x200 in 32-bit colour and shows it in a
  640x400 window (a 320x200 one on a smaller screen).
- OpenGPU's runtime, which OpenUp installs: opengpu.library,
  LIBS:OpenGPU/SDL2.module and LIBS:OpenGPU/SDL2_mixer.module (the sound
  effects and the OGG music).
- About 25 MB of disk (19 MB of it is the music).


Installing
----------

Unpack the archive anywhere (on AmiCradle: SYS:Utilities/OpenCompress x
davegnukem-...lha RAM:), then double-click Install-DaveGnukem beside the
DaveGnukem drawer: it checks for a 68040 with FPU and for SDL2.module and
SDL2_mixer.module (in LIBS:GFOpenGPU/, or copied there from
LIBS:OpenGPU/), asks where to put the game (Work:Games by default) and
updates an earlier install in place, keeping its userdata drawer.


Using it
--------

Open the DaveGnukem icon, or run it from a Shell: it finds its data through
PROGDIR:data/, so from any directory. Settings, the saved game, high scores,
F10 screenshots and the log go in the userdata drawer beside the program
(upstream: ~/.gnukem).

Shell options, as upstream's: -f (full screen), -scale N (window N times
320x200; up to 4 here), -datadir DIR. The in-game menu (Esc) can switch
to full screen and back. Keys are upstream's (arrows, Ctrl to jump, Alt to
fire, Up to act; they can be redefined in the menu). The level editor is
upstream's (a debug key in the game).


How it is built: the route
--------------------------

Dave Gnukem 1.0.3 is SDL 2 only (Matteo Bini's port from SDL 1.2): an
SDL_Window, an SDL_Renderer and a texture updated from a 320x200 32-bit
surface each frame, SDL 2 key codes, and SDL2_mixer for WAV effects and OGG
music. So it is built on OpenGPU's SDL 2 kit with upstream's SDL 2 code
unchanged; the SDL 1.2 route (acsdl12) would have meant undoing upstream's
SDL 2 port. Why 1.0.3: it is the last release tag; master is 180 commits of
work in progress past it (localisation, TTF and PNG support, new data).

What the port changes (all under __amigaos__):

- Paths: DATA_DIR is PROGDIR:data/ (amiga/Makefile.amigaos), the user
  folder is PROGDIR:userdata (src/djstring.cpp), path joins don't put a '/'
  after a ':' (src/djstring.cpp, src/datadir.cpp), and djFolderExists()
  asks AmigaDOS without a trailing '/'.
- Byte order: the game keeps 32-bit pixels as native 0xAARRGGBB values and
  reads and writes them that way (PutPixel/GetPixel, the drop shadows, the
  viewport shadow effect, the EGA/CGA filter). The TGA loader
  (src/djimage.cpp) now stores them that way on the 68k too, and the
  sprite surfaces use the same masks as on little-endian machines
  (src/sdl/djgraph.cpp); upstream's big-endian masks for PPC are left for
  other systems. The simulated EGA/CGA modes, off on big-endian upstream,
  are on here. The level, save, high-score and settings files are bytes
  and text: nothing to swap. All the data's TGAs are uncompressed 24 or
  32-bit.
- Window: the default size is capped at twice 320x200 (upstream takes the
  biggest multiple that fits the desktop; each pixel is scaled on the 68k).
  -scale still goes higher.
- amiga/amiga_screens.c (from the Seven Kingdoms port): after SDL_Quit()
  closes the empty "SDL" screens SDL2.module 0.6 leaves after full screen.
- amiga/stack.c: 256 KB of stack (8 KB message buffers in sys_error.cpp),
  and the $VER string.
- amiga/pthread_stubs.c: what libgcc's unwinder asks of POSIX threads.

Build (GFOpenAmigaGCC 16.2.0-open4 or later; the defaults are CradleLab's
paths). The data is a separate repository, as upstream has it:

    amiga/get-data.sh     # gnukem_data at its tag 1.0.3, into data/
    make -f amiga/Makefile.amigaos -j2 \
         STOVE=$HOME/CradleLab/toolchain/openamigagcc-16.2.0-open4-x86_64-linux \
         NDK=$HOME/CradleLab/gfopensdk/OpenNDK/Include_H \
         SDL2KIT=/mnt/amigachrome/team2/deps/opengpu-sdk

Output: dist/DaveGnukem/ (DaveGnukem, ReadMe, README-gnukem, Credits-data,
COPYING.txt, MIT-LICENSE.txt, data/ without the Windows icon folder, an
empty userdata/, and an icon for each) and dist/DaveGnukem.info. Flags:
-noixemul -m68040 -m68881 -O2 -std=c++14 -Wall and GCC 16's
-fno-tree-loop-distribute-patterns; upstream's files and amiga/ build with
no warnings.

Icons: amiga/icons/icons.json, from our own GlowIcon art
(amiga/icons/art/davegnukem.svg):

    python3 AMICRADLE/scripts/port_icons.py amiga/icons/icons.json --out amiga/icons


Licences
--------

The code: MIT or GPL 2 (MIT-LICENSE.txt, COPYING.txt). The data
(Credits-data, from gnukem_data's README.md, and debian/copyright): MIT or
GPL 2, except the 6x8 font (Zingot Games), key_pickup.wav (Vinrax),
shoot_cg1_modified.wav (Michel Baradari) and the boots sprite (Freepik),
CC BY 3.0, and four of Juhani Junkala's sounds, CC0. The music in
data/music/eric_matyas is Eric Matyas's (https://soundimage.org/), free to
use with credit, which upstream gives in its README; it ships with the game
upstream and in Debian's davegnukem-data. All of it may be redistributed
with the game.


Known limits / to check in the lab
----------------------------------

- Not run yet: picture (colours and alpha of sprites and shadows: the byte
  order fix above), sound and OGG music through SDL2_mixer.module, keys,
  full screen (-f and the menu toggle) and the screens left after it,
  saving into userdata.
- Speed: every frame is a 320x200 32-bit texture update plus the scale to
  the window. -scale 1 is the fastest window.
- The music is 13 OGG tracks, decoded by SDL2_mixer.module; a track that
  fails to load is skipped (upstream checks Mix_LoadMUS).


Standard keys
-------------

Every AmiCradle game has the same keys on Right Amiga (GFOpenUp's
SDL2.module, after 0.8.26):

- Right Amiga + F: window or full screen, remembered for next time
- Right Amiga + P: pause (Right Amiga + P again goes on)
- Right Amiga + Q: quit
- Right Amiga + M: free the mouse pointer, or let the game take it again
- Right Amiga + S: a screenshot in the drawer's Screenshots
- Help: this game's keys (the drawer's Controls file)
- Right Amiga + F1, F2: F11, F12; Right Amiga + cursor keys: Page Up,
  Page Down, Home, End

The FULLSCREEN tooltype on the game's icon (take the brackets off) starts
it full screen.
