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

.include "../monitor.inc"
.include "../memory.inc"
.include "../io/textio.inc"
.include "gr.inc"

.export Title


.DATA
GR_TITLE_00 :  .byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
GR_TITLE_01 :  .byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
GR_TITLE_02 :  .byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
GR_TITLE_03 :  .byte $0,$0,$99,$99,$99,$99,$99,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$99,$99,$99,$99,$99,$0
GR_TITLE_04 :  .byte $0,$0,$99,$99,$99,$99,$99,$0,$0,$88,$88,$88,$88,$0,$0,$88,$88,$88,$88,$0,$0,$0,$88,$88,$0,$0,$0,$88,$88,$88,$88,$88,$0,$0,$99,$99,$99,$99,$99,$0
GR_TITLE_05 :  .byte $0,$0,$99,$0,$0,$0,$0,$0,$88,$0,$0,$0,$0,$0,$88,$0,$0,$0,$0,$0,$0,$88,$0,$0,$88,$0,$0,$88,$0,$0,$0,$0,$88,$0,$99,$0,$0,$0,$0,$0
GR_TITLE_06 :  .byte $0,$0,$99,$0,$0,$0,$0,$0,$88,$0,$0,$0,$0,$0,$88,$0,$0,$0,$0,$0,$88,$0,$0,$0,$0,$88,$0,$88,$0,$0,$0,$0,$88,$0,$99,$0,$0,$0,$0,$0
GR_TITLE_07 :  .byte $0,$0,$99,$99,$99,$0,$0,$0,$88,$88,$88,$88,$0,$0,$88,$0,$0,$0,$0,$0,$88,$0,$0,$0,$0,$88,$0,$88,$88,$88,$88,$88,$0,$0,$99,$99,$99,$0,$0,$0
GR_TITLE_08 :  .byte $0,$0,$99,$0,$0,$0,$0,$0,$0,$0,$0,$0,$88,$0,$88,$0,$0,$0,$0,$0,$88,$88,$88,$88,$88,$88,$0,$88,$0,$0,$0,$0,$0,$0,$99,$0,$0,$0,$0,$0
GR_TITLE_09 :  .byte $0,$0,$99,$0,$0,$0,$0,$0,$0,$0,$0,$0,$88,$0,$88,$0,$0,$0,$0,$0,$88,$0,$0,$0,$0,$88,$0,$88,$0,$0,$0,$0,$0,$0,$99,$0,$0,$0,$0,$0
GR_TITLE_10 :  .byte $0,$0,$99,$99,$99,$99,$99,$0,$88,$0,$0,$0,$88,$0,$88,$0,$0,$0,$0,$0,$88,$0,$0,$0,$0,$88,$0,$88,$0,$0,$0,$0,$0,$0,$99,$99,$99,$99,$99,$0
GR_TITLE_11 :  .byte $0,$0,$99,$99,$99,$99,$99,$0,$88,$88,$88,$88,$0,$0,$0,$88,$88,$88,$88,$0,$88,$0,$0,$0,$0,$88,$0,$88,$0,$0,$0,$0,$0,$0,$99,$99,$99,$99,$99,$0
GR_TITLE_12 :  .byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
GR_TITLE_13 :  .byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
GR_TITLE_14 :  .byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$55,$55,$55,$55,$0,$0,$55,$55,$55,$55,$55,$55,$0,$55,$55,$55,$55,$55,$55,$0,$55,$55,$55,$55,$55,$0,$0,$0
GR_TITLE_15 :  .byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$55,$0,$0,$0,$0,$55,$0,$0,$0,$0,$0,$0,$55,$0,$55,$0,$0,$0,$0,$0,$0,$55,$0,$0,$0,$0,$55,$0,$0
GR_TITLE_16 :  .byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$55,$55,$55,$55,$55,$55,$0,$55,$55,$55,$55,$55,$55,$0,$55,$55,$55,$55,$0,$0,$0,$55,$55,$55,$55,$55,$0,$0,$0
GR_TITLE_17 :  .byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$55,$0,$0,$0,$0,$55,$0,$55,$0,$0,$0,$0,$0,$0,$55,$0,$0,$0,$0,$0,$0,$55,$0,$0,$0,$0,$0,$0,$0
GR_TITLE_18 :  .byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$55,$0,$0,$0,$0,$55,$0,$55,$55,$55,$55,$55,$55,$0,$55,$0,$0,$0,$0,$0,$0,$55,$0,$0,$0,$0,$0,$0,$0
GR_TITLE_19 :  .byte $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0


.CODE


Scroll:

  ldx #39
  loop_scroll:
    lda TXT1_LINE1, X
    sta TXT1_LINE0, X
    lda TXT1_LINE2, X
    sta TXT1_LINE1, X
    lda TXT1_LINE3, X
    sta TXT1_LINE2, X
    lda TXT1_LINE4, X
    sta TXT1_LINE3, X
    lda TXT1_LINE5, X
    sta TXT1_LINE4, X
    lda TXT1_LINE6, X
    sta TXT1_LINE5, X
    lda TXT1_LINE7, X
    sta TXT1_LINE6, X
    lda TXT1_LINE8, X
    sta TXT1_LINE7, X
    lda TXT1_LINE9, X
    sta TXT1_LINE8, X
    lda TXT1_LINE10, X
    sta TXT1_LINE9, X
    lda TXT1_LINE11, X
    sta TXT1_LINE10, X
    lda TXT1_LINE12, X
    sta TXT1_LINE11, X
    lda TXT1_LINE13, X
    sta TXT1_LINE12, X
    lda TXT1_LINE14, X
    sta TXT1_LINE13, X
    lda TXT1_LINE15, X
    sta TXT1_LINE14, X
    lda TXT1_LINE16, X
    sta TXT1_LINE15, X
    lda TXT1_LINE17, X
    sta TXT1_LINE16, X
    lda TXT1_LINE18, X
    sta TXT1_LINE17, X
    lda TXT1_LINE19, X
    sta TXT1_LINE18, X
    dex
    bpl loop_scroll

  rts

.DATA
Title_Scr_Addr:
  .word  GR_TITLE_01, GR_TITLE_02, GR_TITLE_03, GR_TITLE_04, GR_TITLE_05, GR_TITLE_06, GR_TITLE_07, GR_TITLE_08, GR_TITLE_09, GR_TITLE_10
  .word  GR_TITLE_11, GR_TITLE_12, GR_TITLE_13, GR_TITLE_14, GR_TITLE_15, GR_TITLE_16, GR_TITLE_17, GR_TITLE_18, GR_TITLE_19

.CODE
; @brief Displays's the title screen and main game menu
Title:

    ; Title Screen
    jsr Clear_Gr1
    jsr ClearTxt

    sta $C054   ; page 1
    sta $C056   ; lores
    sta $C050   ; gfx
    sta $C053   ; mixed mode on

    ldy #$FE
    loop_scrolling:
      lda #$A2    ; wait for 66ms
      jsr WAIT
      ldx #39
      loop_lines:
          lda GR_TITLE_00, X 
          sta TXT1_LINE19, X
          dex
          bpl loop_lines      
      jsr Scroll    
      iny
      iny
      lda Title_Scr_Addr, Y 
      sta loop_lines+1
      lda Title_Scr_Addr+1, Y
      sta loop_lines+2
      cpy #$26
      bne loop_scrolling

    rts