
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
.include "io/files.inc"

.export _main

; functions
.import world_init
.import player_init
.import view_init
.import game_loop
.import Title
.import level_reset_states

.import memcpy
.import memset
.import meminit

; data
.import __CODE2_LOAD__
.import __CODE2_RUN__
.import __CODE2_SIZE__
.import __RODATA_LOAD__
.import __RODATA_RUN__
.import __RODATA_SIZE__
.import __DATA_LOAD__
.import __DATA_RUN__
.import __DATA_SIZE__

.DATA

STR_EMPTY:   ASCIIZ " "
STR_NEWGAME: ASCIIZ "(N)EW GAME"
STR_JOURNEY: ASCIIZ "(J)OURNEY ONWARD"
STR_NAME:    ASCIIZ "WHAT'S YOUR NAME, ADVENTURER?"

.CODE

_main:

    ; jsr meminit       // Uncomment to zero memory, for debug

    ; Relocations after the HGR "hole"
    ; relocating code
    lda #<__CODE2_LOAD__
    sta FROM
    lda #>__CODE2_LOAD__
    sta FROM+1
    lda #<__CODE2_RUN__
    sta TO 
    lda #>__CODE2_RUN__
    sta TO+1
    lda #<__CODE2_SIZE__
    sta SIZEL
    lda #>__CODE2_SIZE__
    sta SIZEH
    jsr memcpy
    ; relocating RODATA
    lda #<__RODATA_LOAD__
    sta FROM
    lda #>__RODATA_LOAD__
    sta FROM+1
    lda #<__RODATA_RUN__
    sta TO 
    lda #>__RODATA_RUN__
    sta TO+1
    lda #<__RODATA_SIZE__
    sta SIZEL
    lda #>__RODATA_SIZE__
    sta SIZEH
    jsr memcpy
    ; relocating DATA
    lda #<__DATA_LOAD__
    sta FROM
    lda #>__DATA_LOAD__
    sta FROM+1
    lda #<__DATA_RUN__
    sta TO 
    lda #>__DATA_RUN__
    sta TO+1
    lda #<__DATA_SIZE__
    sta SIZEL
    lda #>__DATA_SIZE__
    sta SIZEH
    jsr memcpy

    jsr _StartMenu   ; will init the seed

    ; overwrite the seed to debug
    ; lda #$0
    ; sta SEED0
    ; lda #$0
    ; sta SEED1
    ; lda #$0
    ; sta SEED2
    ; lda #$0
    ; sta SEED3

    jsr Random8_Init

    ; Run
    jsr game_loop    

    rts


; @brief Starting game menu
_StartMenu:

    ; Scrolling Title
    jsr Title

    ; New game or continue
    lda #>STR_NEWGAME
    ldx #<STR_NEWGAME
    jsr Print
    lda #>STR_JOURNEY
    ldx #<STR_JOURNEY
    jsr Print
kbd_wait:
        lda KEYBD
        bpl kbd_wait

    sta KEYBD_STROBE
    
    cmp #($4E + $80)    ; 'N'
    beq new_game
    cmp #($6E + $80)    ; 'n'
    beq new_game

    cmp #($4A + $80)    ; 'J'
    beq journey_onward    
    cmp #($6A + $80)    ; 'j'
    beq journey_onward    
    
    bne kbd_wait

journey_onward:
    jsr LoadCurrentLevel
    jmp start_menu_end

new_game:   
    ; Ask for name
    lda #>STR_NAME
    ldx #<STR_NAME
    jsr Print
    jsr Cin_Str     ; Init seed

    ; delete progress
    jsr level_reset_states

start_menu_end:

    rts
