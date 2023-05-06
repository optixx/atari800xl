all: run

build:
	mads -l -t dli6.asm

script:
	python raw2bas.py --filename dli6.obx  --start-addr 1536 --strip-header 12

basic: script
	run_atari_basic.sh -run dli6.bas

run: build 
	run_atari_rom.sh dli6.obx

clean:
	rm -f dli6.obx dli6.lab dli6.lst dli6.bas
