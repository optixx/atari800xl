run: compile
	../../bin/run.sh dli2.65o


compile:
	../../bin/atasm dli2.asm -xtest.atr


all: run
