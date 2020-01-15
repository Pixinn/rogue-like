
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


; Must be the same as in memory.inc !!
.define ZERO_2_1    $19
.define ZERO_2_3    $1B
.define ZERO_8_1    $D6 
.define ZERO_8_2    $D7 
.define FROM     ZERO_2_1
.define TO       ZERO_2_3
.define SIZEH    ZERO_8_1
.define SIZEL    ZERO_8_2

.export memcpy
.export TXT1_LINES



.DATA
TXT1_LINES:
.word  $400, $480, $500, $580, $600, $680, $700, $780, $428, $4A8, $528, $5A8, $628, $6A8
.word  $728, $7A8, $450, $4D0, $550, $5D0, $650, $6D0, $750, $7D0

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