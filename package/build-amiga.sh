#!/bin/sh
# The release archive, for Cradle's stove_build (target package): Dave
# Gnukem built with amiga/Makefile.amigaos on the stove's GFOpenGPU
# developer kit (SDL 2 and SDL2_mixer), with the game's data (gnukem_data)
# fetched at its pinned commit by amiga/get-data.sh; then the Makefile's
# package target makes the drawer, and tools/make_package.py makes
# davegnukem-VERSION-68040.lha with its .sha256 and .readme: the DaveGnukem
# drawer (the program and its GlowIcons, data, ReadMe and licences), its
# icon, and beside them the Amiga Installer script Install-DaveGnukem and
# its icon (package/installer/, made by amicradle scripts/port_installer.py
# from package/installer.json). OUT also gets the drawer as it unpacks, as
# DaveGnukem.tar (for a lab), and package.json. VERSION is package/VERSION.
# Nothing is published from here.
# MIT, Copyright (c) 2026 AmiCradle Team.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/.." && pwd)
OUT=${OUT:-"$ROOT/build-amiga-package"}
VERSION=$(cat "$HERE/VERSION")
mkdir -p "$OUT"
OUT=$(CDPATH= cd -- "$OUT" && pwd)
BUILD=$(mktemp -d "${TMPDIR:-/tmp}/davegnukem-package.XXXXXX")
trap 'rm -rf "$BUILD"' EXIT INT TERM
cd "$ROOT"

# A stove's compiler is in its prefix/; the GFOpenGPU kit is in the prefix's
# m68k-amigaos/ (include/SDL2, lib/libSDL2.a).
if [ ! -x "$STOVE/bin/m68k-amigaos-gcc" ] && [ -x "$STOVE/prefix/bin/m68k-amigaos-gcc" ]; then
	STOVE="$STOVE/prefix"
fi
SDL2KIT="$STOVE/m68k-amigaos"
[ -f "$SDL2KIT/lib/libSDL2_mixer.a" ] || { echo "the stove has no GFOpenGPU kit (libSDL2_mixer.a)"; exit 1; }
if [ -z "${NDK:-}" ]; then
	git clone -q --depth 1 https://github.com/DalsinAI/gfopensdk "$BUILD/gfopensdk"
	NDK="$BUILD/gfopensdk/OpenNDK/Include_H"
fi
sh amiga/get-data.sh > "$OUT/data-output.txt" 2>&1 || { tail -n 30 "$OUT/data-output.txt"; exit 1; }
DATA_COMMIT=$(git -C data rev-parse HEAD)

make -f amiga/Makefile.amigaos STOVE="$STOVE" NDK="$NDK" SDL2KIT="$SDL2KIT" -j4 \
	> "$OUT/build-output.txt" 2>&1 || { tail -n 60 "$OUT/build-output.txt"; exit 1; }
cp dist/DaveGnukem/DaveGnukem "$BUILD/DaveGnukem"
# The rest of the drawer as the package target made it. userdata/ is empty
# and LhA keeps files only: the game makes it (and Workbench shows it) on
# its first run.
(cd dist/DaveGnukem && rm -f userdata.info &&
	tar --format=ustar --exclude=./DaveGnukem -cf "$BUILD/drawer.tar" .)

python3 - "$BUILD" "$STOVE/bin/m68k-amigaos-gcc" "DaveGnukem" "$DATA_COMMIT" <<'PY'
import hashlib, json, subprocess, sys
from pathlib import Path
build, cc, exe, data = Path(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4]
git = lambda *a: subprocess.run(["git", *a], capture_output=True, text=True).stdout.strip()
receipt = {
    "executable_sha256": hashlib.sha256((build / exe).read_bytes()).hexdigest(),
    "source_commit": git("rev-parse", "HEAD"),
    "compiler_release": subprocess.run([cc, "--version"], capture_output=True,
                                       text=True).stdout.splitlines()[0],
    "source_date_epoch": int(git("log", "-1", "--format=%ct") or 0),
    "data_commit": data,
}
(build / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
PY
cp "$BUILD/receipt.json" "$OUT/receipt.json"
python3 "$ROOT/tools/make_package.py" --build "$BUILD" --version "$VERSION" --out "$OUT"
