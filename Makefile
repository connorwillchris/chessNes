all:
	ca65 main.s -o main.o --debug-info
	ld65 main.o \
		-o chess.nes -t nes --dbgfile chess.dbgfile

run: all
	fceux chess.nes
