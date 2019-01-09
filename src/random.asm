; code copied form: http://6502.org/source/integers/random/random.html
; copyright Bruce Clark 2004

.include "memory.inc"

.export random8 

.define TMP ZERO_2_1 ; requires 4 bytes
.define MOD ZERO_2_5

.CODE
;.align 256

; Linear congruential pseudo-random number generator
;
; Get the next SEED and obtain an 8-bit random number from it
;
; Requires the RAND subroutine
;
; Enter with:
;
;   accumulator = modulus
;
; Exit with:
;
;   accumulator = random number, 0 <= accumulator < modulus
;
; MOD, TMP, TMP+1, and TMP+2 are overwritten
;
; Note that TMP to TMP+2 are only used after RAND is called.
;
random8: STA MOD    ; store modulus in MOD
         JSR RAND   ; get next seed
         LDA #0     ; multiply SEED by MOD
         STA TMP+2
         STA TMP+1
         STA TMP
         SEC
         ROR MOD    ; shift out modulus, shifting in a 1 (will loop 8 times)
R8A:     BCC R8B    ; branch if a zero was shifted out
         CLC        ; add SEED, keep upper 8 bits of product in accumulator
         TAX
         LDA TMP
         ADC SEED0
         STA TMP
         LDA TMP+1
         ADC SEED1
         STA TMP+1
         LDA TMP+2
         ADC SEED2
         STA TMP+2
         TXA
         ADC SEED3
R8B:     ROR        ; shift product right
         ROR TMP+2
         ROR TMP+1
         ROR TMP
         LSR MOD    ; loop until all 8 bits of MOD have been shifted out
         BNE R8A
         RTS



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
; TMP, TMP+1, TMP+2 and TMP+3 are overwritten
;
; Assuming that (a) SEED0 to SEED3 and TMP+0 to TMP+3 are all located on page
; zero, and (b) none of the branches cross a page boundary:
;
;   Space: 106 bytes
;   Speed: JSR RAND takes 517 cycles
;

RAND:    CLC         ; copy SEED into TMP
         LDA SEED0   ; and compute SEED = SEED * $10000 + SEED + 1
         STA TMP
         ADC #1
         STA SEED0
         LDA SEED1
         STA TMP+1
         ADC #0
         STA SEED1
         LDA SEED2
         STA TMP+2
         ADC TMP
         STA SEED2
         LDA SEED3
         STA TMP+3
         ADC TMP+1
         STA SEED3
;
; Bit 7 of $00, $19, $66, and $0D is 0, so only 6 shifts are necessary
;
         LDY #5
RAND1:   ASL TMP     ; shift TMP (old seed) left
         ROL TMP+1
         ROL TMP+2
         ROL TMP+3
;
; Get X from the RAND4 table.  When:
;
; X = $00, SEED = SEED + $10000 * TMP
; X = $01, SEED = SEED + $100 * TMP
; X = $FE, SEED = SEED + $10000 * TMP + TMP
; X = $FF, SEED = SEED + $100 * TMP + TMP
;
         LDX RAND4,Y
         BPL RAND2   ; branch if X = $00 or X = $01
         CLC         ; SEED = SEED + TMP
         LDA SEED0
         ADC TMP
         STA SEED0
         LDA SEED1
         ADC TMP+1
         STA SEED1
         LDA SEED2
         ADC TMP+2
         STA SEED2
         LDA SEED3
         ADC TMP+3
         STA SEED3
         INX         ; $FE -> $00, $FF -> $01
         INX
RAND2:   CLC
         BEQ RAND3   ; if X = $00, SEED = SEED + TMP * $10000
         LDA SEED1   ; SEED = SEED + TMP * $100
         ADC TMP
         STA SEED1
RAND3:   LDA SEED2
         ADC TMP,X
         STA SEED2
         LDA SEED3
         ADC TMP+1,X
         STA SEED3
         DEY
         BPL RAND1
         RTS
RAND4:   .byte  $01,$01,$00,$FE,$FF,$01


