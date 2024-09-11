all: run

build:
	mads -l -t dli7.asm

script: build
	../scripts/obx2bas.py --filename dli7.obx --start-addr 16384 --strip-header 12

basic: script
	run.sh -b dli7.bas

run: build 
	run.sh -r dli7.obx

clean:
	rm -f dli7.obx dli7.lab dli7.lst dli7.bas
