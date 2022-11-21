
; Copyright (C) 2019 Christophe Meneboeuf <christophe@xtof.info>
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

.include "memory.inc"

.export memcpy
.export memset
.export meminit


.CODE

; http://www.6502.org/source/general/memory_move.html
; Move memory up
;
; FROM = source start address
;   TO = destination start address
; SIZE = number of bytes to move
;
memcpy:  LDX SIZEH    ; the last byte must be moved first
         CLC          ; start at the final pages of FROM and TO
         TXA
         ADC FROM+1
         STA FROM+1
         CLC
         TXA
         ADC TO+1
         STA TO+1
         INX          ; allows the use of BNE after the DEX below
         LDY SIZEL
         BEQ MU3
         DEY          ; move bytes on the last page first
         BEQ MU2
MU1:     LDA (FROM),Y
         STA (TO),Y
         DEY
         BNE MU1
MU2:     LDA (FROM),Y ; handle Y = 0 separately
         STA (TO),Y
MU3:     DEY
         DEC FROM+1   ; move the next page (if any)
         DEC TO+1
         DEX
         BNE MU1
         RTS

; Sets a block of memory to the provided value 
;
; A    = value to set
; TO   = memory to be set starting address
; SIZE = number of bytes to set. Max value: $FEFF
;
; !!! TO and SIZE are overwritten !!
memset:
    cmp SIZEH
    beq memset_remain
memset_loop_hi:
    ldy #$FF
memset_loop_low:
    sta (TO),Y
    dey
    bne memset_loop_low
    sta (TO),Y
    inc TO+1        ; next 256 byte block
    dec SIZEH
    bne memset_loop_hi
memset_remain:
    ldy SIZEL
    cpy #0
    beq memset_end
memset_loop_remain:
    sta (TO),Y
    dey
    bne memset_loop_remain
memset_end:
    rts

; DEBUG: zeros the useful memory locations
meminit:

    lda #0
    sta TO
    ldx #$60
    stx TO+1
    ldx #$FF
    stx SIZEL
    ldx #$05
    stx SIZEH
    jsr memset

    lda #0
    sta ZERO_2_1
    sta ZERO_2_2
    sta ZERO_2_3
    sta ZERO_2_4
    sta ZERO_2_5
    sta ZERO_2_6
    sta ZERO_3
    sta ZERO_4_1
    sta ZERO_4_2
    sta ZERO_4_3
    sta ZERO_4_4
    sta ZERO_4_5
    sta ZERO_5_1
    sta ZERO_5_2
    sta ZERO_5_3
    sta ZERO_5_4
    sta ZERO_5_5
    sta ZERO_5_6
    sta ZERO_7_1
    sta ZERO_7_2
    sta ZERO_8_1
    sta ZERO_8_2
    sta ZERO_9_1
    sta ZERO_9_2
    sta ZERO_9_3
    sta ZERO_9_4
    sta ZERO_9_5
    sta ZERO_9_6
    sta ZERO_9_7
    sta ZERO_9_8
    sta ZERO_9_9
    sta ZERO_9_10

    rts