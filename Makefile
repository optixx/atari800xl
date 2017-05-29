run: compile
	../../bin/run.sh dli3.65o


compile:
	../../bin/atasm dli3.asm -xtest.atr


all: run
