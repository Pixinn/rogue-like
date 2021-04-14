
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
.include "actors.inc"
.include "../io/textio.inc"
.include "../math.inc"
.include "../monitor.inc"
.include "../memory.inc"
.include "../world/world.inc"
.include "../world/level.inc"

.import World
.import Random8
.import Grow_Maze ; to patch
.import Compute_Maze_Addr

.export Get_Size_Maze
.export Init_Dimensions_Maze
.export Build_Level

.export Rooms
.export WIDTH_MAZE
.export HEIGHT_MAZE

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
STR_ACTORS:     ASCIIZ "PLACING ACTORS..."

.CODE


; DEPRECATED!!!
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
        ldx #LEVELSIZE::TINY
        ldy #LEVELSIZE::TINY
        rts
    tst_small:
        cmp #$C2
        bne tst_medium
        ldx #LEVELSIZE::SMALL
        ldy #LEVELSIZE::SMALL
        rts
    tst_medium:
        cmp #$C3
        bne tst_big
        ldx #LEVELSIZE::NORMAL
        ldy #LEVELSIZE::NORMAL
        rts
    tst_big:
        cmp #$C4
        bne tst_huge
        ldx #LEVELSIZE::BIG
        ldy #LEVELSIZE::BIG
        rts
    tst_huge:
        cmp #$C5
        bne bad_size
        ldx #LEVELSIZE::HUGE
        ldy #LEVELSIZE::HUGE
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
    ; patch HEIGHT_MAZE usage NO MORE PATCH: comment to be removed
    sty HEIGHT_MAZE
    dey
    dey
    sty _build_fences + $12
    
    rts

; @brief Builds a whole level
; @param Uses NextLevel to get the conf
; @return player position in X and Y
.define DST_WORLD World
.define ADDR_TO_PATCH init_world_line + 3
.define NB_ROOMS ZERO_9_9
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
    ; patching back for a future execution
    lda #<DST_WORLD
    sta ADDR_TO_PATCH
    lda #>DST_WORLD
    sta ADDR_TO_PATCH+1
    
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

    PRINT STR_ACTORS    
    ; the two following defines must be the same as in Place_Actors
    .define POS_X               ZERO_3  ; ROOM_X in Place_Actors
    .define POS_Y               ZERO_2_4  ; ROOM_Y in Place_Actors
    .define POS_STARDOWN_X      ZERO_5_1      
    .define POS_STARDOWN_Y      ZERO_5_2
    .define ACTOR               ZERO_4_1
    .define ACTOR_NB            ZERO_4_2
    .define CURR_ACTOR_OFFSET   ZERO_4_3
    .define POS_PLAYER_OFFSET   ZERO_4_4
    .define LEVEL_CONF_OFFSET   ZERO_5_3
    .define ADDR_ACTOR          ZERO_4_3  ; 2 bytes

    lda #0
    sta ACTOR    
    ldx NextLevel
    stx FAC1
    ldx #SIZEOF_CONF_LEVEL
    stx FAC2
    jsr mul8          ; A = offset to level conf
    txa
    sta LEVEL_CONF_OFFSET
    clc
    adc #7            ; A = offset to pos_player_enter
    sta POS_PLAYER_OFFSET
    tax
    inx
    inx               ; offset to actors[AA_NB]
    loop_actors:
        stx CURR_ACTOR_OFFSET
        lda Levels, X ; actors[AA_NB]
        sta ACTOR_NB 
        loop_actor_nb:
            beq end_loop_actor_nb

            ldx ACTOR
            lda ActiveActor_Tiles, X
            ldx NB_ROOMS
            jsr Place_Actors

            ; save stair down position
            lda ACTOR       
            cmp #eACTORSREACTIVE::AA_STAIRDOWN
            bne not_stair_down
                lda POS_X
                sta POS_STARDOWN_X
                lda POS_Y
                sta POS_STARDOWN_Y
            not_stair_down:

            dec ACTOR_NB            ; next
            jmp loop_actor_nb
        end_loop_actor_nb:

    ldx CURR_ACTOR_OFFSET
    inx
    inc ACTOR
    ldy ACTOR
    cpy #eACTORSREACTIVE::AA_NB
    bne loop_actors
    
    ; Set the 1st position of the player in the level
    ldx POS_PLAYER_OFFSET
    lda Levels, X
    cmp #$FF
    bne not_first_entry
        ; Very first entrance in the level
        lda NextLevel
        cmp #0
        bne not_first_level
            ; Special case: first level
            ; TODO avoid non empty floor...
            ldx Rooms+2 ; Rooms[0].x
            ldy Rooms+3 ; Rooms[0].y
            rts
    not_first_level:
        ldx POS_STARDOWN_X
        ldy POS_STARDOWN_Y
        jsr Compute_Maze_Addr
        ; addr offseted by - witdh_maze to access all tiles with offset        
        sta ADDR_ACTOR+1
        txa
        sec
        sbc #WIDTH_WORLD
        sta ADDR_ACTOR
        lda ADDR_ACTOR+1
        sbc #0
        sta ADDR_ACTOR+1
        ldx POS_STARDOWN_X
        ; NOTE: There is at least one solution, the tile is not surrounded!
        ; if (World[pos_stair_down.y][pos_stair_down.x - 1] == FLOOR_2)
        ldy #(WIDTH_WORLD - 1)
        lda (ADDR_ACTOR), Y
        cmp #ACTORS::FLOOR_2
        bne not_x_minus
            ldy POS_STARDOWN_Y
            dex
            rts
        not_x_minus:
        ; if (World[pos_stair_down.y - 1][pos_stair_down.x] == FLOOR_2)
        ldy #0
        lda (ADDR_ACTOR), Y
        cmp #ACTORS::FLOOR_2
        bne not_y_minus        
            ldy POS_STARDOWN_Y
            dey
            rts
        not_y_minus:
        ; if (World[pos_stair_down.y + 1][pos_stair_down.x] == FLOOR_2)
        ldy #(WIDTH_WORLD * 2)
        lda (ADDR_ACTOR), Y
        cmp #ACTORS::FLOOR_2
        bne not_y_plus
            ldy POS_STARDOWN_Y
            iny
            rts
        not_y_plus:
            ldy POS_STARDOWN_Y
            inx
            rts
    not_first_entry:
        pha             ; pos_player_enter.x
        inx
        lda Levels, X   ; pos_player_enter.y
        tay
        pla
        tax
        rts


    ; ldx NB_ROOMS
    ; lda #ACTORS::STAIR_DOWN
    ; jsr Place_Actors
    ; lda #ACTORS::STAIR_UP
    ; ldx NB_ROOMS
    ; jsr Place_Actors

    rts

