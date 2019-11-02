all: run

build:
	mads hello.asm

run: build
	run_atari_rom.sh hello.obx

clean:
	rm -f hello.obx
