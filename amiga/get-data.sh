#!/bin/sh
# The game's data is its own repository (gnukem_data); upstream's README
# has it cloned as data/ beside src/. The Amiga build uses its tag 1.0.3,
# the data released with the game's 1.0.3.
set -e
cd "$(dirname "$0")/.."
[ -d data/.git ] || git clone https://github.com/davidjoffe/gnukem_data.git data
git -C data checkout -q 46ccb592857b1cacb66665d45a7d981546ff25a4
