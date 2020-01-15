
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

.include "random.inc"
.include "memory.inc"
.include "monitor.inc"
.include "display_map.inc"
.include "builder/builder.inc"
.include "io/textio.inc"

.export _main

.import world_init
.import player_init
.import view_init
.import game_loop

.import Title

.import __MAIN_LAST__
.import __DATA_START__
.import __DATA_SIZE__



.CODE

_main:

    ; Relocate DATA from its freshly loaded location to __DATA_START__
    ; computing DATA actual starting address
    lda #<__MAIN_LAST__
    sta FROM
    lda #>__MAIN_LAST__
    sta FROM+1
    lda #<__DATA_START__
    sta TO 
    lda #>__DATA_START__
    sta TO+1
    lda #<__DATA_SIZE__
    sta SIZEL
    lda #>__DATA_SIZE__
    sta SIZEH
    jsr memcpy

    lda #$0
    sta SEED0
    lda #$0
    sta SEED1
    lda #$0
    sta SEED2
    lda #$0
    sta SEED3
    jsr Title   ; will init the seed

    ; overwrite the seed to debug
    ; lda #$5A
    ; sta SEED0
    ; lda #$5D
    ; sta SEED1
    ; lda #0
    ; sta SEED2
    ; lda #0
    ; sta SEED3
    jsr Random8_Init


    jsr Get_Size_Maze
    jsr Init_Dimensions_Maze
    jsr Build_Level


    ; Init
    jsr Display_Map_Init
    ldx Rooms+2 ; Rooms[0].x
    ldy Rooms+3 ; Rooms[0].y
    jsr player_init
    jsr world_init 
    jsr view_init

    ; Run
    jsr game_loop
    

    rts
