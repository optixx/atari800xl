all: run

build:
	mads main.asm

run: build
	run_atari_rom.sh main.obx

clean:
	rm -f main.obx
