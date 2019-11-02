all: run

build:
	mads dli2.asm

run: build
	run_atari_rom.sh dli2.obx

clean:
	rm -f dli2.obx
