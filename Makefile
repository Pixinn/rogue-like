APPLE2_CL	:= $(CC65_HOME)/bin/cl65
APPLE2_SRC	:= 	src/main.asm src/math.asm src/memory.asm src/random.asm \
				src/game_loop.asm src/display.asm src/tiles.asm src/player.asm \
				src/world/world.asm src/world/level.asm \
				src/builder/builder.asm src/builder/rooms.asm src/builder/maze.asm src/builder/unite.asm \
				src/actors/reactions.asm src/actors/actors.asm \
				src/debug.asm src/display_map.asm \
				src/io/title.asm src/io/textio.asm src/io/gr.asm src/io/files.asm
APPLE2_MAP  := escape.map
APPLE2_CFLAGS	:= -Oirs -v -t apple2 -vm --cpu 6502
APPLE2_OUT	:= floppy/ESCAPE

all:	apple2

apple2: $(APPLE2_SRC)
		$(APPLE2_CL) -m $(APPLE2_MAP) -o $(APPLE2_OUT) $? $(APPLE2_CFLAGS) -C src/escape.cfg

clean:	$(SRC)
	rm -f $(APPLE2_MAP) floppy/ESCAPE src/*.o src/builder/*.o src/io/*.o src/world/*.o src/actors/*.o gmon.out

install: apple2
		 ./scripts/add-to-disk.sh $(APPLE_COMMANDER) ./floppy escape.dsk
		 