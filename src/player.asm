
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
.include "memory.inc"
.include "monitor.inc"
.include "io/textio.inc"


; init the player's structures
.export player_init

; All the following functions returns the new player position:
; x in X and y in Y
; They may be unmodified ;)
; DESTROY A, X, Y, ZERO_2_1, ZERO_2_2

; Increments Player's X position
.export player_move_inx
; Increments Player's Y position
.export player_move_iny
; Decrements Player's X position
.export player_move_dex
; Decrements Player's Y position
.export player_move_dey

; Player coordinates in the maze ([0:255], [0:255])
.export Player_XY

.import Compute_Maze_Addr


.BSS

Player_XY: .res 2


.CODE

STR_GO_UP:      ASCIIZ "YOU GO NORTH"
STR_GO_RIGHT:   ASCIIZ "YOU GO EAST"
STR_GO_DOWN:    ASCIIZ "YOU GO SOUTH"
STR_GO_LEFT:    ASCIIZ "YOU GO WEST"
STR_HIT_WALL:   ASCIIZ "YOU HIT A WALL"

; @brief Player initial coords
; @param X player's x
; @param Y player's y
player_init:
    stx Player_XY
    sty Player_XY+1
    rts


; !!! ALL THE MOVE FUNCTION HAVE TO BE GROUPED TOGHETHER
; AS THERE IS A COMMON RETURN POINT TO WHICH THEY BRANHC (KEEP PC's DISTANCE < 127) !!!

.define ADDR_IN_MAZE ZERO_2_1
player_move_inx:

    ; test that x+1 is "WALKABLE" 
    ldx Player_XY
    ldy Player_XY+1
    jsr Compute_Maze_Addr           ; we get the adress for x,y then we increment x
    stx ADDR_IN_MAZE
    sta ADDR_IN_MAZE+1
    ldy #1                          ; will look at x+1
    lda #ACTORS::WALKABLE
    cmp (ADDR_IN_MAZE), Y
    bcc hit_wall                    ; carry cleared if A is strictly the lesser --> not walkable
    ldx Player_XY
    inx
    stx Player_XY                   ; walkable
    PRINT STR_GO_RIGHT
    jmp return_from_player_move



player_move_dex:

    ; test that x-1 is "WALKABLE" 
    ldx Player_XY
    dex                     
    ldy Player_XY+1
    jsr Compute_Maze_Addr           ; we get the adress for x-1
    stx ADDR_IN_MAZE
    sta ADDR_IN_MAZE+1
    ldy #0                          ; will look at x-1
    lda #ACTORS::WALKABLE
    cmp (ADDR_IN_MAZE), Y
    bcc hit_wall     ; carry cleared if A is strictly the lesser --> not walkable
    ldx Player_XY
    dex
    stx Player_XY                   ; walkable
    PRINT STR_GO_LEFT
    jmp return_from_player_move


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
    

player_move_iny:

    ; test that y+1 is "WALKABLE" 
    ldy Player_XY+1 
    ldx Player_XY
    iny
    jsr Compute_Maze_Addr ; we get the adress for x,y+1
    stx ADDR_IN_MAZE 
    sta ADDR_IN_MAZE+1
    ldy #0
    lda #ACTORS::WALKABLE
    cmp (ADDR_IN_MAZE), Y
    bcc hit_wall     ; carry cleared if A is strictly the lesser --> not walkable
    
    ldy Player_XY+1             ; walkable
    iny
    sty Player_XY+1         
    PRINT STR_GO_DOWN
    jmp return_from_player_move


player_move_dey:

    ; test that y-1 is "WALKABLE" 
    ldy Player_XY+1 
    ldx Player_XY
    dey
    jsr Compute_Maze_Addr ; we get the adress for x,y-1
    stx ADDR_IN_MAZE 
    sta ADDR_IN_MAZE+1
    ldy #0
    lda #ACTORS::WALKABLE
    cmp (ADDR_IN_MAZE), Y
    bcc hit_wall     ; carry cleared if A is strictly the lesser --> not walkable
    
    ldy Player_XY+1             ; walkable
    dey
    sty Player_XY+1         
    PRINT STR_GO_UP
    bvc return_from_player_move


    .undef ADDR_IN_MAZE
