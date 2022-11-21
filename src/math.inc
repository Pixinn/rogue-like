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


.define FAC1     ZERO_7_1
.define FAC2     ZERO_7_2

.import mul8
.import Modulus
.import div8

; Inverts a positive number to its 2's complement counterpart
; The bits are all reversed then one is added 
; param : number to be inverted in in A
; result : in A
.macro NEG 
    eor #$FF ; %11111111 to reverse bits
    clc
    adc #$01
.endmacro


.macro ADD16 addr, csteL, csteH
    clc
    lda addr
    adc csteL
    sta addr
    lda addr+1
    adc csteH
    sta addr+1
.endmacro


.macro DEC16 addr, cste
    sec
    lda addr
    sbc cste
    sta addr
    lda addr+1
    sbc #0
    sta addr+1
.endmacro

