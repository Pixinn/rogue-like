
; Copyright (C) 2018 Christophe Meneboeuf <christophe@xtof.info>
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


.include "world.inc"
.include "../tiles.inc"
.include "../random.inc"
.include "../math.inc"
.include "../memory.inc"



.export World

; initializes the world
; DESTROYS A,X,Y, ZERO_2_1, ZERO_2_2, ZERO_2_3
.export world_init

; sets the player's position onto the Maze
; in: X = x coord in the maze
; in: Y = y coord in the maze
; out : X and Y as they where given
; DESTROYS A,X,Y, ZERO_2_1, ZERO_2_2, ZERO_2_4, ZERO_2_5
.export world_set_player

; Computes the adress corresponding to the coordinates in the maze
; in: X = x coord in the maze
; in: Y = y coord in the maze
; out: AX = Address corresponding to (x,y) in the World array
; DESTROYS A,X,Y, ZERO_2_1, ZERO_2_2, ZERO_2_3
.export Compute_Maze_Addr


.define TILE_NR     ZERO_2_1
.define COORD_X     ZERO_2_1
.define COORD_Y     ZERO_2_2
.define OFFSET      ZERO_2_2


.BSS

; The tile where the player stands
.struct Tile_player_standing
    addr     .word   ; adress of the location 
    actor     .byte  ; actor on the location tile
.endstruct

.CODE

; @param X Player's x
; @param Y Player's y
world_init:
    ; Saving the first tile on which the player stands
    ; FIXME player could be standing anywhere on any type of floor
    jsr Compute_Maze_Addr
    stx Tile_player_standing::addr
    sta Tile_player_standing::addr+1
    stx ZERO_2_1
    sta ZERO_2_1+1
    ldy #0
    lda (ZERO_2_1), Y
    sta Tile_player_standing::actor

    rts


; sets the player's position onto the World
world_set_player:

    stx ZERO_2_4
    sty ZERO_2_5

    ; restore the previous tile
    ldx Tile_player_standing::addr
    lda Tile_player_standing::addr+1
    stx ZERO_2_1
    sta ZERO_2_1+1
    ldy #0
    lda Tile_player_standing::actor
    sta (ZERO_2_1), Y

    ; save the next tile
    ldx ZERO_2_4
    ldy ZERO_2_5
    jsr Compute_Maze_Addr   ; get's player's position address in memory
    stx Tile_player_standing::addr
    sta Tile_player_standing::addr+1
    stx ZERO_2_1
    sta ZERO_2_1+1
    ldy #0
    lda (ZERO_2_1), y
    sta Tile_player_standing::actor

    ; sets the player on the tile
    lda #ACTORS::PLAYER 
    sta (ZERO_2_1), y

    ; restore the given locations
    ldx ZERO_2_4
    ldy ZERO_2_5

    rts

; Destroys ZERO_2_1, ZERO_2_2, ZERO_2_3 ZERO_7_1 and ZERO_7_2
Compute_Maze_Addr:

    stx COORD_X

    ; offset due to Y coord
    sty FAC1
    lda #WIDTH_WORLD
    sta FAC2
    jsr mul8
    tay ; high part of the mul
    txa ; low part of the mul

    ; adding offset due to X
    clc
    adc COORD_X
    sta OFFSET
    tya
    adc #0
    sta OFFSET+1

    ; adding the offset to the address
    lda #<World
    clc
    adc OFFSET
    tax             ; low part of address to be returned in X
    lda #>World
    adc OFFSET+1    ; high part of address to be returned in A

    rts



.DATA

.align 256

World: .res (WIDTH_WORLD) * (HEIGHT_WORLD)
