all: run

build:
	mads -l -t dli8.asm

script: build
	../scripts/obx2bas.py --filename dli8.obx --start-addr 16384 --strip-header 12

basic: script
	run.sh -b dli8.bas

run: build 
	run.sh -r dli8.obx

clean:
	rm -f dli8.obx dli8.lab dli8.lst dli8.bas
