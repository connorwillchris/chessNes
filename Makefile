all: build

build:
	ca65 main.s -o main.o --debug-info
	ld65 main.o -o chess.nes -t nes --dbgfile chess.dbgfile

run: build
	fceux chess.nes

clean:
	rm -rf *.o
	rm -rf *.nes
	rm -rf *.dbgfile
