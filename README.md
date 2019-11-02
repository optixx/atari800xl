# Atari 800 XL assembler code demos

Some examples i collected while learing assembler for the Atari 800 XL

- dli1
- dli2
- dli3
- dli4
- dli6
- hello
- weganoid

## Usage

1. Install [mads](http://mads.atari8.info/) assembler into your path
2. Install [atari800](https://atari800.github.io/) emulator into your path
3. Create helper scripts into your path to start the emulator

```
#!/bin/sh
ATARI_PATH="~/Devel/arch/atari"
${ATARI_PATH}/bin/atari800 -pal -xe -xlxe_rom ${ATARI_PATH}/roms/ATARIXL.ROM -video-accel -win-width 800 -win-height 600 "$1"
```

4. Build and run an example
```
cd hello 
make all
make run
```


## Links
* [mads](http://mads.atari8.info/) - MADS multi-pass crossassembler 
* [atari800](https://atari800.github.io/) - Atari800 portable and free Atari 8-bit emulator
