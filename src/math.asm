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


; 8 bit division
;     Inputs:
;         FAC1 = 8-bit numerator
;         FAC2 = 8-bit denominator
;     Outputs:
;         FAC1 = 8-bit quotient of TQ / B
;         A = remainder of TQ / B
; source: http://6502org.wikidot.com/software-math-intdiv
; div8:
;    lda #0
;    ldx #8
;    asl FAC1
; lbl_1:
;    rol A
;    cmp FAC2
;    bcc lbl_2
;    sbc FAC2
; lbl_2:
;    rol FAC1
;    dex 
;    bne lbl_1

;    rts 


; source: https://www.codebase64.org/doku.php?id=base:8bit_divide_8bit_product
; 8bit/8bit division
; by White Flame
;
; Input: num, denom in zeropage
; Output: num = quotient, .A = remainder

; div8:
;  lda #$00
;  ldx #$07
;  clc
; : rol FAC1
;   rol
;   cmp FAC2
;   bcc :+
;    sbc FAC2
; : dex
;  bpl :--
;  rol FAC1

; 19 bytes
;
;  Best case  = 154 cycles
;  Worst case = 170 cycles
;
; With immediate denom:
;  Best case  = 146 cycles 
;  Worst case = 162 cycles
;
; Unrolled with variable denom:
;  Best case  = 106 cycles
;  Worst case = 127 cycles
;
; Unrolled with immediate denom:
;  Best case  =  98 cycles
;  Worst case = 111 cycles

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
