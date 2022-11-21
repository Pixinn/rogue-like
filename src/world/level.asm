
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
.include "../math.inc"
.include "../actors/actors.inc"
.include "../builder/builder.inc"
.include "../io/files.inc"
.include "level_private.inc"

; code
.export levels_init
.export level_enter
.export level_exit
.export level_get_config_offset
.export level_reset_states
; data
.export LevelConfigs
.export NbLevels
.export CurrentLevel
.export NextLevel
.export ExitLevel
.export LevelIsBuilt

.import player_init
.import ActorsInLevel
.import ActorPositions
.import World

.BSS

CurrentLevel:   .res    1
NbLevels:       .res    1
NextLevel:      .res    1
ExitLevel:      .res    1
LevelIsBuilt:   .res    1


LevelConfigs:     .res    1 + NB_LEVELS * SIZEOF_CONF_LEVEL


.segment "CODE2"


.define ACCUMULATOR         ZERO_9_4    ; 2 bytes

; @param LevelNr in X
_Set_Params_LoadSaveLevelActors:

    ; compute offset in file
    lda #0
    sta ACCUMULATOR
    sta ACCUMULATOR+1
    beq end_loop_offset
loop_offset: ; accumulating offsets
    clc
    lda ACCUMULATOR
    adc #<(SIZEOF_ACTORS_T)
    sta ACCUMULATOR
    lda ACCUMULATOR+1
    adc #>(SIZEOF_ACTORS_T)
    sta ACCUMULATOR+1
    dex
    bne loop_offset
end_loop_offset:
    ; set function parameters
    sta Param_FileOffset+3
    lda ACCUMULATOR
    sta Param_FileOffset+2
    lda #<Str_FileLevelsActors
    sta Param_FileOpen+1
    lda #>Str_FileLevelsActors
    sta Param_FileOpen+2
    lda #<ActorsInLevel
    sta Param_FilesReadWrite+2
    lda #>ActorsInLevel
    sta Param_FilesReadWrite+3

    rts


.define NR_LEVELS ZERO_4_1
levels_init:

    ; file path
    lda #<Str_FileLevelConfs
    sta Param_FileOpen+1
    lda #>Str_FileLevelConfs
    sta Param_FileOpen+2
    ; read buffer
    lda #0
    sta Param_FileOffset+2
    sta Param_FileOffset+3
    sta Param_FileOffset+4
    lda #<LevelConfigs
    sta Param_FilesReadWrite+2
    lda #>LevelConfigs
    sta Param_FilesReadWrite+3
    lda #<(1 + SIZEOF_CONF_LEVEL * NB_LEVELS)
    sta Param_FilesReadWrite+4
    lda #>(1 + SIZEOF_CONF_LEVEL * NB_LEVELS)
    sta Param_FilesReadWrite+5

    ; load
    jsr ReadFile
    
    ; exploit
    lda LevelConfigs
    sta NbLevels
    sta NR_LEVELS
    inc NR_LEVELS

; global vars
    lda #0
    sta CurrentLevel
    sta NextLevel
    lda #FALSE
    sta ExitLevel

    rts



; @param: Uses NextLevel as level number
.define LEVEL_STATE_OFFSET  ZERO_9_1
.define ADDR_LEVEL_CONF     ZERO_9_2    ; 2 bytes
level_enter:

    lda NextLevel
    jsr LoadState

    lda LevelIsBuilt
    cmp #TRUE
    beq level_was_built

level_generation:

        ; compute offset to level config
        lda NextLevel
        jsr level_get_config_offset
        pha
        clc
        txa
        adc #<LevelConfigs
        sta ADDR_LEVEL_CONF
        pla
        adc #>LevelConfigs
        sta ADDR_LEVEL_CONF+1    

        ; init maze size
        ldy #1
        lda (ADDR_LEVEL_CONF), Y ; size
        tax
        tay
        jsr Init_Dimensions_Maze

        ; player position returned in X and Y    
        jsr Build_Level
        jsr player_init     ; param: player pos in X and Y      

level_was_built:

        ldx ActorPositions + eACTORTYPES::PLAYER
        ldy ActorPositions + eACTORTYPES::PLAYER + 1
        jsr player_init

level_enter_end:

    lda #FALSE
    sta ExitLevel

    lda NextLevel
    sta CurrentLevel

    rts


.define Player_XY ActorPositions + eACTORTYPES::PLAYER
level_exit:

    lda CurrentLevel
    jsr SaveState

    rts

; @param Level_Nr in A
; @return Config offset for the level in X
level_get_config_offset:

    sta FAC1
    ldx #SIZEOF_CONF_LEVEL
    stx FAC2
    jsr mul8
    ; first byte of conf is the number of levels
    pha
    clc
    txa
    adc #1
    tax
    pla
    adc #0

    rts

; @brief reset the states of all levels
level_reset_states:
    
    lda #0
    sta CurrentLevel
    lda #NB_LEVELS
    jsr ResetIsBuilt

    rts
