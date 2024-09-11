#!/bin/sh
ATARI_PATH="/Users/david/Devel/arch/atari"

ROM="${ATARI_PATH}/roms/ATARIXL.ROM"
BASIC="${ATARI_PATH}/roms/ATARIBAS.ROM"
TBASIC="${ATARI_PATH}/floppies/turbobasic/TURBO-BASIC_XL-Cartridge.car"
DEFAULT="-pal -xl -video-accel -win-width 1440 -win-height 1152"

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--rom)
      atari800 ${DEFAULT} -xlxe_rom ${ROM} "$2"
      shift
      ;;
    -b|--basic)
      atari800 ${DEFAULT} -xlxe_rom ${ROM} -basic_rom ${BASIC} "$2"
      shift
      ;;
    -t|--turbobasic)
      atari800 ${DEFAULT} -xlxe_rom ${ROM} -cart ${TBASIC} "$2"
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

