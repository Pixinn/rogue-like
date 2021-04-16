
; Copyright (C) 2021 Christophe Meneboeuf <christophe@xtof.info>
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

.include "../common.inc"
.include "../memory.inc"
.include "../random.inc"
.include "../builder/actors.inc"
.include "../builder/builder.inc"
.include "level_private.inc"

; code
.export levels_init
.export level_enter
.export level_exit
; data
.export Levels
.export CurrentLevel
.export NextLevel
.export ExitLevel

.import player_init

.BSS

CurrentLevel:   .res    1
NextLevel:      .res    1
ExitLevel:      .res    1

.align 256          ; to be sure it is accessible with an offset
Levels:         .res    SIZEOF_CONF_LEVEL * NB_LEVELS



.CODE


.define NR_ACTORS ZERO_4_1
.define NR_LEVELS ZERO_4_2
; TODO Load a configuration file from disk!
levels_init:

    ldx #0
    ldy #0
    lda #NB_LEVELS
    sta NR_LEVELS

level_conf_default:
    ; level_nr
    tya
    iny
    sta Levels, X
    ; is_built
    lda FALSE
    sta Levels+1, x
    ; seed
    lda #0
    sta Levels+2, X
    sta Levels+3, X
    sta Levels+4, X
    sta Levels+5, X  
    ; size
    ; pos_player_enter
    lda #$FF
    sta Levels+7, X
    sta Levels+8, X  
    ; actors
    txa
    clc
    adc #9
    tax
    lda #eACTORSREACTIVE::AA_NB
    sta NR_ACTORS
    lda #0

    level_conf_actors:        
        sta  Levels, X
        inx
        dec NR_ACTORS
        bne level_conf_actors

    dec NR_LEVELS
    bne level_conf_default

    ; level #0
    ldx #0
    lda #1
    sta Levels + 9 + eACTORSREACTIVE::AA_STAIRUP, X
    lda #LEVELSIZE::TINY
    sta Levels+6, X ; size
    ; level #1
    clc
    txa
    adc #SIZEOF_CONF_LEVEL
    tax
    lda #1
    sta Levels + 9 + eACTORSREACTIVE::AA_STAIRUP, X
    sta Levels + 9 + eACTORSREACTIVE::AA_STAIRDOWN, X
    lda #LEVELSIZE::SMALL
    sta Levels+6, X ; size
    ; level #2
    clc
    txa
    adc #SIZEOF_CONF_LEVEL
    tax
    lda #1
    sta Levels + 9 + eACTORSREACTIVE::AA_STAIRUP, X
    sta Levels + 9 + eACTORSREACTIVE::AA_STAIRDOWN, X
    lda #LEVELSIZE::NORMAL
    sta Levels+6, X ; size
    ; level #3
    clc
    txa
    adc #SIZEOF_CONF_LEVEL
    tax
    lda #1
    sta Levels + 9 + eACTORSREACTIVE::AA_STAIRUP, X
    sta Levels + 9 + eACTORSREACTIVE::AA_STAIRDOWN, X
    lda #LEVELSIZE::BIG
    sta Levels+6, X ; size
    ; level #4
    clc
    txa
    adc #SIZEOF_CONF_LEVEL
    tax
    lda #1
    sta Levels + 9 + eACTORSREACTIVE::AA_STAIRDOWN, X
    lda #LEVELSIZE::HUGE
    sta Levels+6, X ; size

    ; global vars
    lda #0
    sta CurrentLevel
    lda FALSE
    sta ExitLevel

    rts



; @param: Uses NextLevel as level number
.define LEVEL_CONF_OFFSET ZERO_3
level_enter:

    ; debug:
    ; lda NextLevel
    ; cmp #0
    ; bne debug_end
    ;     jsr Random8
    ; debug_end:

    jsr Random8_SaveRandomness

    ; get the level conf
    lda #0
    ldx #0
    clc
    get_level_conf:
        tay
        lda Levels, X
        cmp NextLevel
        beq end_idx_level
        tya
        adc #SIZEOF_CONF_LEVEL
        tax
        bcc get_level_conf
    end_idx_level:
    stx LEVEL_CONF_OFFSET

    ; init seed for the level if not already built
    lda Levels+1, X   ; is_built
    cmp FALSE
    bne end_init_seed

    jsr Random8
    ldx LEVEL_CONF_OFFSET
    sta Levels+2, X ; seed[0]
    jsr Random8
    ldx LEVEL_CONF_OFFSET
    sta Levels+3, X ; seed[1]
    jsr Random8
    ldx LEVEL_CONF_OFFSET
    sta Levels+4, X ; seed[2]
    jsr Random8
    ldx LEVEL_CONF_OFFSET
    sta Levels+5, X ; seed[3]
end_init_seed:

    ; init the randomness with the values for the level
    lda Levels+2, X ; seed[0]
    sta SEED0
    lda Levels+3, X ; seed[1]
    sta SEED1
    lda Levels+4, X ; seed[2]
    sta SEED2
    lda Levels+5, X ; seed[3]
    sta SEED3
    jsr Random8_Init
    
    ; init maze size
    ldx LEVEL_CONF_OFFSET
    txa
    pha ; save LEVEL_CONF_OFFSET as its ZP will be overwritten
    lda Levels+6, X ; size
    tax
    tay
    jsr Init_Dimensions_Maze

    ; player position returned in X and Y
    jsr Build_Level
    jsr player_init     ; param: player pos in X and Y

    jsr Random8_RestoreRandomness

    pla ; restore LEVEL_CONF_OFFSET
    tax
    lda TRUE
    sta Levels+1, X; is_built

    lda FALSE
    sta ExitLevel

    lda NextLevel
    sta CurrentLevel

    rts


.import Player_XY
level_exit:

    ; get the level conf
    lda #0
    ldx #0
    clc
    get_level_conf_2:
        tay
        lda Levels, X
        cmp CurrentLevel
        beq end_idx_level_2
        tya
        adc #SIZEOF_CONF_LEVEL
        tax
        bcc get_level_conf_2
    end_idx_level_2:

    ; save player pos in conf
    lda Player_XY
    sta Levels+7, X
    lda Player_XY + 1
    sta Levels+8, X 

    rts
