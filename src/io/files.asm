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


; TODO a lot of code space can be spared by factorizing ReadState and Write state. Almos the same code


.include "../actors/actors.inc"
.include "../world/level.inc"
.include "../world/world.inc"
.include "../common.inc"
.include "../memory.inc"
.include "../math.inc"

.import World
.import ActorsInLevel
.import LevelIsBuilt
.import PlayerTile
.import Tile_player_standing_actor

; data
; TODO : should remain private!!
.export Str_FileLevelConfs
.export Str_FileLevelsActors
.export Param_FileOpen
.export Param_FileOffset
.export Param_FilesReadWrite
.export File_Buffer


; functions
.export ReadFile
.export LoadState
.export SaveState
.export ResetIsBuilt
.export LoadCurrentLevel

.define TO_PATCH 0

; reserve 1024 bytes for MLI file operations in the upper part of HGR2
File_Buffer := $5C00


.RODATA

Str_FileLevelConfs:
.byte $19, "/PRODOS.2.4.2/LEVELS.CONF"    ; Pascal string
Str_FileLevelsActors:
.byte $19, "/PRODOS.2.4.2/LEVELS.ACTS"    ; Pascal string
Str_FileStates:
.byte $14, "/PRODOS.2.4.2/STATES"         ; Pascal string

.BSS

Lvl_Nr: .res 1

.define MIN_READ_SIZE 256
ReadWriteBuffer: .res MIN_READ_SIZE

.DATA 

Param_FileOpen:
    .byte $3                    ; in - nb params
    .addr TO_PATCH              ; in - char* filepath
    .addr File_Buffer           ; in - char* workbuffer
    Handle_File:
    .byte $0                    ; out - handle on the file

Param_FileOffset:
    .byte $2                     ; in - nb params
    .byte TO_PATCH               ; in - handle on the file
    .byte TO_PATCH, TO_PATCH, 0  ; in - Offset

Param_FilesReadWrite:
    .byte $4                     ; in - nb params
    .byte TO_PATCH               ; in - handle on the file
    .addr TO_PATCH               ; in - out buffer
    .word TO_PATCH               ; in - max nb bytes to WRITE/READ
    .word $0000                  ; out - nb bytes write/read

Param_FileClose:
    .byte $1                    ; in - nb params
    .byte TO_PATCH              ; in - handle on the file
    


.CODE

; TODO handle errors
ReadFile:

    ; Open the file
    jsr $BF00   ; call MLI
.byte $C8       ; Open
.addr Param_FileOpen 

    ; Set read position
    lda Handle_File
    sta Param_FileOffset+1
    jsr $BF00   ; call MLI
.byte $CE       ; Set Mark
.addr Param_FileOffset 

    ; Read the file
    lda Handle_File
    sta Param_FilesReadWrite+1
    jsr $BF00   ; call MLI
.byte $CA       ; read
.addr Param_FilesReadWrite

    ; Close the file
    lda Handle_File
    sta Param_FileClose+1
    jsr $BF00   ; call MLI
.byte $CC       ; Close
.addr Param_FileClose
    rts



.define READ_DST ZERO_2_4 ; 2 bytes

; @brief Offset in A:X (little endian)
;        HandleFile must have been set by opening the file
_SetOffset:

    sta Param_FileOffset+2
    stx Param_FileOffset+3
    lda Handle_File
    sta Param_FileOffset+1
    jsr $BF00   ; call MLI
.byte $CE       ; Set Mark
.addr Param_FileOffset    

    rts

; @brief Size in in A:X (little endian)
;        Destination ptr in READ_DST: cannot be locate in ZERO PAGE!!!
;        HandleFile must have been set by opening the file
_Read:

    ; Read the file
    sta Param_FilesReadWrite+4
    stx Param_FilesReadWrite+5
    lda Handle_File
    sta Param_FilesReadWrite+1
    lda READ_DST
    sta Param_FilesReadWrite+2
    lda READ_DST+1
    sta Param_FilesReadWrite+3
    jsr $BF00   ; call MLI
.byte $CA       ; read
.addr Param_FilesReadWrite

    rts

; @param   LevelNr in A
; @return  isBuilt in A
; modifies ZERO_2_3, ZERO_2_4, ZERO_2_5
.define LVLS_HEADER_SIZE    4
.define LVL_HEADER_SIZE     3
.define OFFSET       Param_FileOffset+2
; compute offset and sets file position
_FindLevelLayout:    

    ; Compute the level state offset in file    
    ldy #(LVLS_HEADER_SIZE + 2 + LVL_HEADER_SIZE)   ; +2: current lvl + nb lvls
    sty OFFSET
    lda #0
    sta OFFSET+1
    lda Lvl_Nr
    tax
    cpx #0
    beq end_acc_offset_lvl
acc_offset_lvl:
        ADD16 OFFSET, #<(HEIGHT_WORLD * WIDTH_WORLD), #>(HEIGHT_WORLD * WIDTH_WORLD)
        ADD16 OFFSET, #(LVL_HEADER_SIZE + 2), #0   ; +2: visited + tile
        dex
        bne acc_offset_lvl
end_acc_offset_lvl:

    ; Set read position
    lda OFFSET
    ldx OFFSET+1
    jsr _SetOffset

    rts


.define ACTSS_HEADER_SIZE  4;
.define ACT_HEADER_SIZE   3;
_FindLevelActors:

    ; Compute offset
    lda #(LVLS_HEADER_SIZE + 2)
    sta OFFSET
    lda #0
    sta OFFSET+1
    ldx NbLevels
acc_offset_lvls:        
        ADD16 OFFSET, #<(HEIGHT_WORLD * WIDTH_WORLD), #>(HEIGHT_WORLD * WIDTH_WORLD)
        ADD16 OFFSET, #(LVL_HEADER_SIZE + 2), #0   ; +2: visited + tile
        dex        
        bne acc_offset_lvls
    ADD16 OFFSET, #(ACTSS_HEADER_SIZE + ACT_HEADER_SIZE), #0

    ldx Lvl_Nr
    cpx #0
    beq end_acc_offset_actors
acc_offset_actors:
        ADD16 OFFSET, #<(ACT_HEADER_SIZE + SIZEOF_ACTORS_T), #>(ACT_HEADER_SIZE + SIZEOF_ACTORS_T)
        dex
        bne acc_offset_actors
end_acc_offset_actors:
    
    ; Set read position
    lda OFFSET
    ldx OFFSET+1
    jsr _SetOffset    

    rts

; @param Level NR in A
LoadState:    

    sta Lvl_Nr

    ; Open the file
    lda #<Str_FileStates
    sta Param_FileOpen+1
    lda #>Str_FileStates
    sta Param_FileOpen+2
    jsr $BF00   ; call MLI
    .byte $C8   ; Open
    .addr Param_FileOpen     

    ; save the new current level
    lda #(LVLS_HEADER_SIZE) 
    ldx #0
    jsr _SetOffset ; current lvl
    lda #<Lvl_Nr
    sta READ_DST
    lda #>Lvl_Nr
    sta READ_DST+1
    lda #1
    ldx #0
    jsr _Write  

    lda Lvl_Nr
    jsr _FindLevelLayout ; compute offset and sets file read position    
               
    lda #<ReadWriteBuffer
    sta READ_DST
    lda #>ReadWriteBuffer
    sta READ_DST+1
    lda #<MIN_READ_SIZE
    ldx #>MIN_READ_SIZE
    jsr _Read 
    lda ReadWriteBuffer
    sta LevelIsBuilt
    lda ReadWriteBuffer+1
    sta Tile_player_standing_actor

    lda LevelIsBuilt
    cmp #FALSE
    beq LoadState_end

    ; Read the level's layout
    ; Set read position
    ADD16 OFFSET, #2, #0 ; offset past "visited" & "tile"
    lda OFFSET
    ldx OFFSET+1
    jsr _SetOffset
    ; Read the file
    lda #<World
    sta READ_DST
    lda #>World
    sta READ_DST+1
    lda #<(HEIGHT_WORLD * WIDTH_WORLD)
    ldx #>(HEIGHT_WORLD * WIDTH_WORLD)
    jsr _Read

    ; Read level actors state
    jsr _FindLevelActors ; compute offset and sets file read position
    ; Read the file
    lda #<ActorsInLevel
    sta READ_DST
    lda #>ActorsInLevel
    sta READ_DST+1
    lda #<(SIZEOF_ACTORS_T)
    ldx #>(SIZEOF_ACTORS_T)
    jsr _Read    

LoadState_end:    

    ; Close the file
    lda Handle_File
    sta Param_FileClose+1
    jsr $BF00   ; call MLI
.byte $CC       ; Close
.addr Param_FileClose

    rts



.define WRITE_DST ZERO_2_4 ; 2 bytes
; @brief Size in in A:X (little endian)
;        Destination ptr in WRITE_DST: cannot be locate in ZERO PAGE!!!
;        HandleFile must have been set by opening the file
_Write:

    ; Wr the file
    sta Param_FilesReadWrite+4
    stx Param_FilesReadWrite+5
    lda Handle_File
    sta Param_FilesReadWrite+1
    lda WRITE_DST
    sta Param_FilesReadWrite+2
    lda WRITE_DST+1
    sta Param_FilesReadWrite+3
    jsr $BF00   ; call MLI
.byte $CB       ; write
.addr Param_FilesReadWrite

    rts


; @param Level NR in A
SaveState:    

    sta Lvl_Nr

    ; Open the file
    lda #<Str_FileStates
    sta Param_FileOpen+1
    lda #>Str_FileStates
    sta Param_FileOpen+2
    jsr $BF00   ; call MLI
    .byte $C8   ; Open
    .addr Param_FileOpen     

    lda Lvl_Nr
    jsr _FindLevelLayout ; compute offset and sets file write position   

    ; Write the file
    lda #TRUE
    sta ReadWriteBuffer 
    lda Tile_player_standing_actor
    sta ReadWriteBuffer+1
    lda #<ReadWriteBuffer
    sta WRITE_DST
    lda #>ReadWriteBuffer
    sta WRITE_DST+1
    lda #<MIN_READ_SIZE
    ldx #>MIN_READ_SIZE
    jsr _Write

    ; Write the level's layout
    ; Set write position
    ADD16 OFFSET, #2, #0 ; offset past "visited" & "tile"
    lda OFFSET
    ldx OFFSET+1
    jsr _SetOffset    
    ; Write the file
    lda #<World
    sta WRITE_DST
    lda #>World
    sta WRITE_DST+1
    lda #<(HEIGHT_WORLD * WIDTH_WORLD)
    ldx #>(HEIGHT_WORLD * WIDTH_WORLD)
    jsr _Write

    ; Write level actors state
    jsr _FindLevelActors ; compute offset and sets file write position
    ; Write the file
    lda #<ActorsInLevel
    sta WRITE_DST
    lda #>ActorsInLevel
    sta WRITE_DST+1
    lda #<(SIZEOF_ACTORS_T)
    ldx #>(SIZEOF_ACTORS_T)
    jsr _Write

    ; Close the file
    lda Handle_File
    sta Param_FileClose+1
    jsr $BF00   ; call MLI
.byte $CC       ; Close
.addr Param_FileClose

    rts

; @param LevelNr in A
ResetIsBuilt:

    sta Lvl_Nr

    ; Open the file
    lda #<Str_FileStates
    sta Param_FileOpen+1
    lda #>Str_FileStates
    sta Param_FileOpen+2
    jsr $BF00   ; call MLI
.byte $C8   ; Open
.addr Param_FileOpen  

for_each_lvl:
        dec Lvl_Nr
        jsr _FindLevelLayout ; compute offset and sets file write position 
        inc Lvl_Nr

        lda #FALSE
        sta ReadWriteBuffer
        lda #<ReadWriteBuffer
        sta WRITE_DST
        lda #>ReadWriteBuffer
        sta WRITE_DST+1
        lda #<MIN_READ_SIZE
        ldx #>MIN_READ_SIZE
        jsr _Write 

        dec Lvl_Nr
        bne for_each_lvl

    ; Close the file
    lda Handle_File
    sta Param_FileClose+1
    jsr $BF00   ; call MLI
.byte $CC       ; Close
.addr Param_FileClose

    rts



LoadCurrentLevel:

    ; Open the file
    lda #<Str_FileStates
    sta Param_FileOpen+1
    lda #>Str_FileStates
    sta Param_FileOpen+2
    jsr $BF00   ; call MLI
.byte $C8   ; Open
.addr Param_FileOpen

    ; load the current level
    lda #(LVLS_HEADER_SIZE) 
    ldx #0
    jsr _SetOffset ; current lvl
    lda #<ReadWriteBuffer
    sta READ_DST
    lda #>ReadWriteBuffer
    sta READ_DST+1
    lda #<MIN_READ_SIZE
    ldx #>MIN_READ_SIZE
    jsr _Read
    lda ReadWriteBuffer
    sta NextLevel

    ; Close the file
    lda Handle_File
    sta Param_FileClose+1
    jsr $BF00   ; call MLI
.byte $CC       ; Close
.addr Param_FileClose

    rts