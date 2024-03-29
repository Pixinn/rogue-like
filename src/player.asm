
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


.include "common.inc"
.include "memory.inc"
.include "monitor.inc"
.include "io/textio.inc"
.include "world/world.inc"
.include "actors/actors.inc"


; init the player's structures
.export player_init

; exectutes the tile's reaction and updates the player's position if possible
; Destroys ZEROS_2_1 -> 2_5
.export player_move

; All the following functions returns the new player position:
; x in X and y in Y
; They may be unmodified ;)
; DESTROY A, X, Y, ZERO_2_1, ZERO_2_2


.import Compute_Maze_Addr
.import Reactions_lsb
.import Reactions_msb
.import ActorTypes
.import ActorPositions


.define TO_BE_PATCHED 0
.define Player_XY ActorPositions + eACTORTYPES::PLAYER

.DATA

STR_HIT_WALL:   ASCIIZ "YOU HIT A WALL"

.CODE

; @brief Player initial coords
; @param X player's x
; @param Y player's y   
player_init:
    stx Player_XY
    sty Player_XY+1
    rts

; @param X target tile's x
; @param Y target tile's y
; @return TRUE in A if the player can move to the tile, FALE otherwise
.define ADDR_IN_MAZE    ZERO_2_1    ; 2 bytes
.define NEW_PLAYER_XY   ZERO_2_4    ; 2 bytes
player_move:

    stx NEW_PLAYER_XY
    sty NEW_PLAYER_XY+1    

    jsr Compute_Maze_Addr

    ; get the actor id
    stx ADDR_IN_MAZE
    sta ADDR_IN_MAZE+1
    ldy #0
    lda (ADDR_IN_MAZE), Y
    tax

    ; get the actor's type
    lda ActorTypes, X
    tay

    ; get the reaction address
    lda Reactions_lsb, Y
    sta FUNC_REACTION + 1
    lda Reactions_msb, Y
    sta FUNC_REACTION+2

    FUNC_REACTION : jsr TO_BE_PATCHED ; actord id in Y
    
    cmp #TRUE
    bne end_player_move
    ldx NEW_PLAYER_XY
    stx Player_XY
    ldy NEW_PLAYER_XY+1
    sty Player_XY+1 
    
end_player_move:
    ldx Player_XY
    ldy Player_XY+1
    
    rts


; Common code to return from the moves.
; Moves BRANCH to here
return_from_player_move:

    ; return player's coordinates
    ldx Player_XY
    ldy Player_XY+1
    rts

hit_wall:
    PRINT STR_HIT_WALL
    jmp return_from_player_move
    
