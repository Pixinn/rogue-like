; Copyright (C) 2020 Christophe Meneboeuf <christophe@xtof.info>
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

; nb of bytes to be displayed in DBG_TRACES[0]
.export DBG_TRACE
; bytes to be displayed
.export DBG_TRACES


.CODE
.define STROUT $DB3A ; Applesoft: OUTPUTS AY-POINTED NULL TERMINATED STRING
.define LINPTR $ED24 ; Applesoft: Displays the number A(high)X(low) in decimal

; Traces the number of TRACES requested
DBG_TRACE:
    ldy #>str_trace
    lda #<str_trace
    jsr STROUT
    
    lda #0   
    loop:
        tax
        inx
        txa
        pha
        lda DBG_TRACES, X
        tax
        lda #0
        jsr LINPTR
        
        ldy #>str_space
        lda #<str_space
        jsr STROUT
        
        pla 
        cmp DBG_TRACES        
        bne loop    
    rts

.DATA
str_trace:  .byte     13, "TRACE: ", 0
str_space:  .byte     " ", 0

.BSS
DBG_TRACES: .res 7      ; bytes to be displayed by TRACE



