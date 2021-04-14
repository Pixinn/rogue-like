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


.include "world/level.inc"
.include "world/world.inc"
.include "display.inc"
.include "display_map.inc"
.include "memory.inc"
.include "monitor.inc"
.include "common.inc"


.export game_loop

; display / view
.import set_view_coords
.import view_refresh
; player
.import player_move
.import player_move_inx
.import player_move_iny
.import player_move_dex
.import player_move_dey
.import Player_XY
; world
.import world_set_player

; ************
.include "builder/builder.inc"
.import world_init
.import player_init
.import view_init
; ************


.define KEY_UP      $C9
.define KEY_LEFT    $CA
.define KEY_DOWN    $CB
.define KEY_RIGHT   $CC
.define TAB         $89


.CODE

    nop         ; Main can jump to a wrong game_loop's addr without this nop :/

; ########### GAME ##########

; @brief Main game loop
game_loop:

    jsr levels_init

    lda #0
    sta NextLevel

    level_loop:
        jsr level_enter ; Uses NextLevel as level number

        ; *****************
    ;   jsr Build_Level
        jsr Display_Map_Init
        ; ldx Rooms+2 ; Rooms[0].x
        ; ldy Rooms+3 ; Rooms[0].y
        ; jsr player_init
        jsr world_init 
        jsr view_init
        ; *****************


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

            lda ExitLevel
            cmp TRUE
            bne kbd_loop

            jsr level_exit

            jmp level_loop

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
    cmp #TAB
    beq display_map
    rts

move_up:
    ldx Player_XY
    ldy Player_XY+1
    dey
    jsr player_move
    ; jsr player_move_dey
    jmp end_action_move
move_right:
    ldx Player_XY    
    ldy Player_XY+1
    inx
    jsr player_move
    ; jsr player_move_inx
    jmp end_action_move
move_down:
    ldx Player_XY
    ldy Player_XY+1
    iny
    jsr player_move
    ; jsr player_move_iny
    jmp end_action_move
move_left:
    ldx Player_XY
    ldy Player_XY+1
    dex
    jsr player_move
    ; jsr player_move_dex
    jmp end_action_move

end_action_move:            ; update player/view coordinates and refresh the display
    jsr world_set_player
    jsr set_view_coords     ; coords of the player in XY after player_move_*
    jsr view_refresh    
    rts



display_map:
    jsr Map_Loop
    rts

