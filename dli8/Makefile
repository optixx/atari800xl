all: run

build:
	mads -l -t dli8.asm

script: build
	../scripts/obx2bas.py --filename dli8.obx --start-addr 16384 --strip-header 12

basic: script
	run_atari_basic.sh -run dli8.bas

run: build 
	run_atari_rom.sh dli8.obx

clean:
	rm -f dli8.obx dli8.lab dli8.lst dli8.bas
