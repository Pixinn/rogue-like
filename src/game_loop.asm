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
.include "display.inc"
.include "memory.inc"
.include "monitor.inc"

.export game_loop

; display / view
.import set_view_coords
.import view_refresh
; player
.import player_move_inx
.import player_move_iny
.import player_move_dex
.import player_move_dey
.import Player_XY
; world
.import world_set_player


.define KEY_UP      $C9
.define KEY_LEFT    $CA
.define KEY_DOWN    $CB
.define KEY_RIGHT   $CC

.CODE

game_loop:

    ldx Player_XY
    ldy Player_XY+1

    jsr world_set_player
    jsr set_view_coords    
    jsr view_refresh

    ; waiting for a key to be pressed
kbd_loop:
        lda KEYBD
        bpl kbd_loop  ; bit #8 is set when a character is present (thus A < 0)
    sta KEYBD_STROBE

    jsr key_action
    bvc kbd_loop

    rts

    ; action on key pressed
key_action:
    cmp #KEY_UP
    beq move_up
    cmp #KEY_RIGHT
    beq move_right
    cmp #KEY_DOWN
    beq move_down
    cmp #KEY_LEFT
    beq move_left
    rts

move_up:
    jsr player_move_dey
    bvc end_action_move
move_right:
    jsr player_move_inx 
    bvc end_action_move
move_down:
    jsr player_move_iny
    bvc end_action_move
move_left:
    jsr player_move_dex
    bvc end_action_move

end_action_move:            ; update player/view coordinates and refresh the display
    jsr world_set_player
    jsr set_view_coords     ; coords of the player in XY after player_move_*
    jsr view_refresh
    rts

