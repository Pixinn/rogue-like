
; Copyright (C) 2019 Christophe Meneboeuf <christophe@xtof.info>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program. If not, see <http://www.gnu.org/licenses/>.


; All the dungeon builder is based on this article: http://journal.stuffwithstuff.com/2014/12/21/rooms-and-mazes/

.include "rooms.inc"
.include "maze.inc"
.include "unite.inc"
.include "../io/textio.inc"
.include "../monitor.inc"
.include "../world.inc"
.include "../memory.inc"

.import World
.import Random8
.import Grow_Maze ; to patch

.export Get_Size_Maze
.export Init_Dimensions_Maze
.export Build_Level

.export Rooms
.export WIDTH_MAZE
.export HEIGHT_MAZE

.define MAX_NB_ROOMS 64     ; MAX_NB_ROOMS *MUST BE* <= 64

.BSS

; Describes a room to be built
; typedef struct {
;     uint8_t height;
;     uint8_t width;
;     uint8_t x;
;     uint8_t y;
; } room_t;
.define SIZEOF_ROOM_T 4
.align 256
Rooms: .res SIZEOF_ROOM_T*MAX_NB_ROOMS  ; MAX 1 page of data!

WIDTH_MAZE:    .res 1
HEIGHT_MAZE:   .res 1

.DATA 
STR_SIZE_MAZE_1:  ASCIIZ "PLEASE ENTER THE SIZE OF THE LEVEL."
STR_SIZE_MAZE_2:  ASCIIZ "A:TINY  B:SMALL  C:NORMAL D:BIG  E:HUGE"
STR_SIZE_MAZE_3:  ASCIIZ "PLEASE ENTER A VALID CHOICE."

STR_ROOMS:      ASCIIZ "CARVING ROOMS..."
STR_MAZE:       ASCIIZ "GROWING THE MAZE..."
STR_DOORS:      ASCIIZ "OPENING DOORS..."
STR_DEADENDS:   ASCIIZ "FILLING DEAD ENDS..."
STR_UNITE:      ASCIIZ "UNITING THE ROOMS..."

.CODE

; @brief Asks for the size of the maze
; Returns Width in X and Height in Y
Get_Size_Maze:
    
    ; User input
    PRINT STR_SIZE_MAZE_1
choice_size_maze:
    PRINT STR_SIZE_MAZE_2
    jsr Cin_Char

    ; switch case over the input
    tst_tiny:
        cmp #$C1
        bne tst_small
        ldx #16
        ldy #16
        rts
    tst_small:
        cmp #$C2
        bne tst_medium
        ldx #24
        ldy #24
        rts
    tst_medium:
        cmp #$C3
        bne tst_big
        ldx #32
        ldy #32
        rts
    tst_big:
        cmp #$C4
        bne tst_huge
        ldx #48
        ldy #48
        rts
    tst_huge:
        cmp #$C5
        bne bad_size
        ldx #64
        ldy #64
        rts
    bad_size:
        PRINT STR_SIZE_MAZE_3
        jmp choice_size_maze


; @brief Fills border walls
; @param type of the "wall" in A
; destroys ZERO_2_1, ZERO_2_2
.define ADDR_WORLD ZERO_2_1
.macro WORLD_NEXT_LINE 
    clc
    lda ADDR_WORLD
    adc #WIDTH_WORLD
    sta ADDR_WORLD
    lda ADDR_WORLD+1
    adc #0
    sta ADDR_WORLD+1
.endmacro
; DO NOT MESS WITH THIS FUNCTION: IT IS PATCHED!!
.define PATCH_WIDTH_MAZE_1 0
.define PATCH_HEIGHT_MAZE_2 0
_build_fences:

    ldx #<World
    stx ADDR_WORLD
    ldx #>World
    stx ADDR_WORLD+1
    ldy #PATCH_WIDTH_MAZE_1

    loop_wall_top:
        sta (ADDR_WORLD), Y
        dey
        bne loop_wall_top
    sta (ADDR_WORLD), Y 

    ldx #PATCH_HEIGHT_MAZE_2
    loop_wall_left_right:
        pha
        WORLD_NEXT_LINE
        pla
        ldy #PATCH_WIDTH_MAZE_1
        sta (ADDR_WORLD), Y
        ldy #0
        sta (ADDR_WORLD), Y
        dex
        bne loop_wall_left_right

    pha
    WORLD_NEXT_LINE
    pla
    ldy #PATCH_WIDTH_MAZE_1
    loop_wall_bottom:
        sta (ADDR_WORLD), Y
        dey
        bne loop_wall_bottom
    sta (ADDR_WORLD), Y

    rts
.undefine ADDR_WORLD

; @brief Sets the Maze's dimentions
; @param width in X
; @param height in Y
Init_Dimensions_Maze:

    stx WIDTH_MAZE
    ; patch WIDTH_MAZE usage NO MORE PATCH: comment to be removed
    dex
    stx _build_fences + $9
    stx _build_fences + $23
    stx _build_fences + $3D
    ; dex
    ; dex
    ; dex
    ; stx Grow_Maze + $C
    ; patch HEIGHT_MAZE usage NO MORE PATCH: comment to be removed
    sty HEIGHT_MAZE
    dey
    dey
    sty _build_fences + $12
    ; dey
    ; dey
    ; sty Grow_Maze + $19
    
    rts

; @brief Builds a whole level
.define DST_WORLD World
.define ADDR_TO_PATCH init_world_line + 3
.define NB_ROOMS ZERO_8_2
Build_Level:

    ; Filling World with ACTORS::WALL_1
    ldy #HEIGHT_WORLD
    init_world:
        ldx #0
        init_world_line:
            lda #ACTORS::WALL_1
            sta DST_WORLD, x
            inx
            cpx #WIDTH_WORLD
            bne init_world_line
        ; patching DST_WORLD
        lda ADDR_TO_PATCH
        clc
        adc #WIDTH_WORLD
        sta ADDR_TO_PATCH
        lda ADDR_TO_PATCH + 1
        adc #0
        sta ADDR_TO_PATCH + 1
        dey
        bne init_world
    
    PRINT STR_ROOMS
    lda #MAX_NB_ROOMS+1
    jsr Carve_Rooms
    sta NB_ROOMS
    
    lda #ACTORS::FLOOR_1
    jsr _build_fences
    
    PRINT STR_MAZE
    jsr Grow_Maze

    lda #ACTORS::WALL_1
    jsr _build_fences

    PRINT STR_DOORS
    .define PERCENT_7 #17
    ldx PERCENT_7
    lda NB_ROOMS
    jsr Connect_Rooms

    PRINT STR_DEADENDS
    jsr Remove_Dead_Ends

    PRINT STR_UNITE
    jsr Unite_Rooms

    rts

