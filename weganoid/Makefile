all: run

build:
	mads weganoid.asm

run: build
	run_atari_rom.sh weganoid.obx

clean:
	rm -f weganoid.obx
