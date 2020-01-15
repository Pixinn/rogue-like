.include "memory.inc"

; Must be the same as in math.inc !!
.define FAC1     ZERO_7_1
.define FAC2     ZERO_7_2

.export mul8
.export Modulus

.CODE

; Short 8bit * 8bit = 16bit multiply
; A small multiplication routine using the ancient egyptian multiplication algorithm.
; Factors should be stored in the FAC1 and FAC2 variables,
; the product can be found in A (high byte) and X (low byte).
; FAC1 will be destroyed. No tables required. 
; Source: http://www.codebase64.org/doku.php?id=base:short_8bit_multiplication_16bit_product
mul8:
        ; A:X = FAC1 * FAC2

        lda #$00
        ldx #$08
        clc
m0:     bcc m1
        clc
        adc FAC2
m1:     ror
        ror FAC1
        dex
        bpl m0
        ldx FAC1
        rts




; Returns A % X in A
; Source: http://forum.6502.org/viewtopic.php?t=130
Modulus:
        sec
        stx FAC2
lbl_modulus:
        sbc FAC2
        bcs lbl_modulus

        adc FAC2

        rts
