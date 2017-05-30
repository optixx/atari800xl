run: compile
	../../bin/run.sh weganoid.65o


compile:
	../../bin/atasm weganoid.asm -xtest.atr


all: run
