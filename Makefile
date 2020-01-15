APPLE2_CL	:= $(CC65_HOME)/bin/cl65
APPLE2_SRC	:= 	src/main.asm src/math.asm src/memory.asm src/random.asm \
				src/game_loop.asm src/display.asm src/tiles.asm src/world.asm src/player.asm \
				src/debug.asm src/builder/builder.asm src/builder/rooms.asm src/builder/maze.asm src/display_map.asm \
				src/io/title.asm src/io/textio.asm src/io/gr.asm
APPLE2_MAP  := escape.map
APPLE2_CFLAGS	:= -Oirs -v -t apple2 -vm --cpu 6502
APPLE2_OUT	:= bin/escape.a2

all:	directories apple2

directories:
	    mkdir -p bin

apple2: $(APPLE2_SRC)
		$(APPLE2_CL) -m $(APPLE2_MAP) -o $(APPLE2_OUT) $? $(APPLE2_CFLAGS) -C src/escape.cfg

clean:	$(SRC)
	rm -f $(APPLE2_MAP) src/*.o src/*.s src/builder/*.o src/builder/*.s src/io/*.s src/io/*.s gmon.out & rm -r bin/
