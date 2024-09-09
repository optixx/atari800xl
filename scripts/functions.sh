#!/bin/sh
ATARI_PATH="/Users/david/Devel/arch/atari"


function run_atari_basic(){
  atari800 -pal -xl -basic -xlxe_rom ${ATARI_PATH}/roms/ATARIXL.ROM -basic_rom ${ATARI_PATH}/roms/ATARIBAS.ROM -video-accel -win-width 800 -win-height 600 $1
}


function run_atari_rom(){
atari800 -pal -xe -xlxe_rom ${ATARI_PATH}/roms/ATARIXL.ROM -video-accel -win-width 800 -win-height 600 "$1"
}

