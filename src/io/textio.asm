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


.include "../memory.inc"

.export CIN_STR
.export Cin_Str
.export Cin_Char
.export Print
.export ClearTxt


.define SPACE     $A0
.define CURSOR    $5F
.define RETURN    $8D
.define DELETE    $FF
.define LEFT      $88


.DATA

CIN_STR:  
.byte 0
.res 40       ; input string buffer char[40]


.CODE

; brief Clears the 4 line in text zone (mixed mode)
ClearTxt:
    ldx #39
    lda #SPACE
    loop_clear_lines:        
        sta TXT1_LINE20, X
        sta TXT1_LINE21, X
        sta TXT1_LINE22, X
        sta TXT1_LINE23, X
        dex
        bpl loop_clear_lines
    rts


; brief Scrolls the lines in text zone (mixed mode)
_ScrollTxt:
    ldx #39
    loop_scroll_lines:     
        lda TXT1_LINE21, X
        sta TXT1_LINE20, X
        lda TXT1_LINE22, X
        sta TXT1_LINE21, X
        lda TXT1_LINE23, X
        sta TXT1_LINE22, X
        lda #SPACE
        sta TXT1_LINE23, X
        dex
        bpl loop_scroll_lines
    rts


.define ADDR_STR     ZERO_7_1   ; 2 bytes same as FAC1 and FAC2
; @brief Print the null terminated str
; @param A,X Adress of the string (hi, low)
Print:
    stx  ADDR_STR
    sta  ADDR_STR+1

    jsr _ScrollTxt

    ldy #0
    loop_print_str:
        lda (ADDR_STR), Y
        cmp #0
        beq break_print_str
        sta TXT1_LINE23, Y
        iny
        cpy #40
        bne loop_print_str
    break_print_str:

    rts

.macro INC_SEED
clc 
lda SEED0
adc #1
sta SEED0
lda SEED1
adc #0
sta SEED1
lda SEED2
adc #0
sta SEED2
lda SEED3
adc #0
sta SEED3
.endmacro


; @brief Gets an input string into the CIN_STR buffer
; @details It will also init the seed
Cin_Str:
    
    jsr _ScrollTxt
    
    ; position the cursor
    ldx #0
    lda #CURSOR
    sta TXT1_LINE23, X

    ; wait for keyboard
    cin_str_kbd_loop:
        INC_SEED
        lda KEYBD
        bpl cin_str_kbd_loop  ; bit #8 is set when a character is present (thus A < 0)
    sta KEYBD_STROBE
    
    cmp #RETURN
    beq break_cin   ; break if "Return"

    cmp #DELETE
    beq delete 

    cmp #LEFT
    beq delete

    ; print key and avance the cursor
    sta TXT1_LINE23, X
    sta CIN_STR, X
    inx
    cpx #40 ; eol -> ends anyway
    beq break_cin
    lda #CURSOR
    sta TXT1_LINE23, X
    jmp cin_str_kbd_loop

    break_cin:
    lda #SPACE
    sta TXT1_LINE23, X  ; erase the cursor
    lda #0
    sta CIN_STR, X
    
    rts

    delete:
    cpx #0  ; cannot delete when at pos 0
    beq cin_str_kbd_loop
    lda #SPACE
    sta TXT1_LINE23, X
    dex
    lda #0
    sta CIN_STR, X
    lda #CURSOR
    sta TXT1_LINE23, X
    jmp cin_str_kbd_loop



; @brief Gets an input char
; @detals Entered char in A
Cin_Char:
     
    jsr _ScrollTxt
    
    lda #CURSOR
    sta TXT1_LINE23

    ; wait for keyboard
    cin_char_kbd_loop:
        lda KEYBD
        bpl cin_char_kbd_loop  ; bit #8 is set when a character is present (thus A < 0)
    sta KEYBD_STROBE
    sta TXT1_LINE23

    rts
