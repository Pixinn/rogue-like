
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
.include "../common.inc"
.include "../actors/actors.inc"
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

; #TRUE if an object has been picked by the player
.export World_PickedObject

.export Tile_player_standing_actor

.define COORD_X     ZERO_2_1
.define COORD_Y     ZERO_2_2
.define OFFSET      ZERO_2_2


.BSS

; The tile where the player stands
; The two memory locations must be adjacent
Tile_player_standing_addr:  .res 2
Tile_player_standing_actor: .res 1

.DATA

World_PickedObject: .byte 0

.CODE

; @param X Player's x
; @param Y Player's y
world_init:
    ; Saving the first tile on which the player stands
    ; FIXME player could be standing anywhere on any type of floor
    jsr Compute_Maze_Addr
    stx Tile_player_standing_addr
    sta Tile_player_standing_addr+1

    lda Tile_player_standing_actor
    cmp #UNDEF
    bne world_init_end
        lda #eACTORTYPES::FLOOR_2
        sta Tile_player_standing_actor

world_init_end:
    rts


; sets the player's position onto the World
.define PLAYER_XY       ZERO_2_1; 2 bytes
.define NEXT_TILE_XY    ZERO_2_4 ; 2 bytes
world_set_player:

    stx NEXT_TILE_XY
    sty NEXT_TILE_XY+1

    ; restore the previous tile    
    ldx Tile_player_standing_addr
    lda Tile_player_standing_addr+1
    stx PLAYER_XY
    sta PLAYER_XY+1
    ldy #0
    lda Tile_player_standing_actor
    sta (PLAYER_XY), Y
    
    ; save the next tile
    ldx NEXT_TILE_XY
    ldy NEXT_TILE_XY+1
    jsr Compute_Maze_Addr   ; get's player's position address in memory
    stx Tile_player_standing_addr
    sta Tile_player_standing_addr+1
    stx PLAYER_XY
    sta PLAYER_XY+1
    ldy #0
    lda (PLAYER_XY), y
    sta Tile_player_standing_actor
    ; if an object was picked
    ; override to force save a floor tile
    lda World_PickedObject
    cmp #TRUE
    bne no_object_picked
        lda #eACTORTYPES::FLOOR_2
        sta Tile_player_standing_actor
        lda #FALSE
        sta World_PickedObject
    no_object_picked:

    ; sets the player on the tile
    lda #eACTORTYPES::PLAYER 
    sta (PLAYER_XY), y

    ; restore the given locations
    ldx NEXT_TILE_XY
    ldy NEXT_TILE_XY+1

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



.BSS

.align 256

World: .res (WIDTH_WORLD) * (HEIGHT_WORLD)
