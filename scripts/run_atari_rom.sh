#!/bin/sh
ATARI_PATH="/Users/david/Devel/arch/atari"
atari800 -pal -xe -xlxe_rom ${ATARI_PATH}/roms/ATARIXL.ROM -video-accel -win-width 800 -win-height 600 "$1"
