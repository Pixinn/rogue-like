; code copied form: http://6502.org/source/integers/random/random.html
; copyright Bruce Clark 2004

.include "memory.inc"

.export Random8
.export Random8_Init
.export Random8_RestoreRandomness
.export Random8_SaveRandomness
.export DBG_SEED

.define TMP RESERVED01

.BSS

.align 256
T0:     .res 256
T1:     .res 256
T2:     .res 256
T3:     .res 256
T0COPY: .res 256

.CODE

DBG_SEED: .byte 0,0,0,0    ; MUST NOT BE RELOCATED!

; Linear congruential pseudo-random number generator
;
; Calculate SEED = 1664525 * SEED + 1
;
; Enter with:
;
;   SEED0 = byte 0 of seed
;   SEED1 = byte 1 of seed
;   SEED2 = byte 2 of seed
;   SEED3 = byte 3 of seed
;
; Returns:
;
;   SEED0 = byte 0 of seed
;   SEED1 = byte 1 of seed
;   SEED2 = byte 2 of seed
;   SEED3 = byte 3 of seed
;
; TMP is overwritten
;
; For maximum speed, locate each table on a page boundary
;
; Assuming that (a) SEED0 to SEED3 and TMP are located on page zero, and (b)
; all four tables start on a page boundary:
;
;   Space: 58 bytes for the routine
;          1024 bytes for the tables
;   Speed: JSR RAND takes 94 cycles
;
Random8:
         CLC       ; compute lower 32 bits of:
         LDX SEED0 ; 1664525 * ($100 * SEED1 + SEED0) + 1
         LDY SEED1
         LDA T0,X
         ADC #1
         STA SEED0
         LDA T1,X
         ADC T0,Y
         STA SEED1
         LDA T2,X
         ADC T1,Y
         STA TMP
         LDA T3,X
         ADC T2,Y
         TAY       ; keep byte 3 in Y for now (for speed)
         CLC       ; add lower 32 bits of:
         LDX SEED2 ; 1664525 * ($10000 * SEED2)
         LDA TMP
         ADC T0,X
         STA SEED2
         TYA
         ADC T1,X
         CLC
         LDX SEED3 ; add lower 32 bits of:
         ADC T0,X  ; 1664525 * ($1000000 * SEED3)
         STA SEED3
         RTS
;
; Generate T0, T1, T2 and T3 tables
;
; A different multiplier can be used by simply replacing the four bytes
; that are commented below
;
; To speed this routine up (which will make the routine one byte longer):
; 1. Delete the first INX instruction
; 2. Replace LDA Tn-1,X with LDA Tn,X (n = 0 to 3)
; 3. Replace STA Tn,X with STA Tn+1,X (n = 0 to 3)
; 4. Insert CPX #$FF between the INX and BNE GT1
;
Random8_Init: 
; Xtof's dbg Saving the seed
         lda SEED0
         sta DBG_SEED
         lda SEED1
         sta DBG_SEED+1
         lda SEED2
         sta DBG_SEED+2
         lda SEED3
         sta DBG_SEED+3
; Xtof's dbg
         LDX #0      ; 1664525 * 0 = 0
         STX T0
         STX T1
         STX T2
         STX T3
         INX
         CLC
GT1:     LDA T0-1,X  ; add 1664525 to previous entry to get next entry
         ADC #$0D    ; byte 0 of multiplier
         STA T0,X
         LDA T1-1,X
         ADC #$66    ; byte 1 of multiplier
         STA T1,X
         LDA T2-1,X
         ADC #$19    ; byte 2 of multiplier
         STA T2,X
         LDA T3-1,X
         ADC #$00    ; byte 3 of multiplier
         STA T3,X
         INX         ; note: carry will be clear here
         BNE GT1
         RTS



Random8_RestoreRandomness:

    ldx #$FF
restore_loop:
    lda T0COPY, X
    sta T0, X
    dex
    bne restore_loop
    lda T0COPY, X
    sta T0, X

    rts


Random8_SaveRandomness:

    ldx #$FF
save_loop:
    lda T0, X
    sta T0COPY, X
    dex
    bne save_loop
    lda T0, X
    sta T0COPY, X

    rts
