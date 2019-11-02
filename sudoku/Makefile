all: run

build:
	mads sudoku.asm

run: build
	run_atari_rom.sh sudoku.obx

clean:
	rm -f sudoku.obx
