# Atari 800 XL assembler code demos

## Overview 

Some examples i collected while learing assembler for the Atari 800 XL

- dli1 - DLI Sample from german Atari Magazine
![](https://github.com/optixx/atari800xl/raw/master/screenshots/dli1.png)
- dli2 - DLI Sample from german Atari Magazine
![](https://github.com/optixx/atari800xl/raw/master/screenshots/dli2.png)
- dli3 - DLI Sample from german Atari Magazine
![](https://github.com/optixx/atari800xl/raw/master/screenshots/dli3.png)
- dli4 - DLI Sample from german Atari Magazine
![](https://github.com/optixx/atari800xl/raw/master/screenshots/dli4.png)
- dli6 - DLI Sample from german Atari Magazine
![](https://github.com/optixx/atari800xl/raw/master/screenshots/dli6.png)
- hello - DLI text sample
![](https://github.com/optixx/atari800xl/raw/master/screenshots/hello.png)
- weganoid - Game from german Atari Magazine
![](https://github.com/optixx/atari800xl/raw/master/screenshots/weganoid.png)

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
```


## Links
* [mads](http://mads.atari8.info/) - MADS multi-pass crossassembler 
* [atari800](https://atari800.github.io/) - Atari800 portable and free Atari 8-bit emulator
