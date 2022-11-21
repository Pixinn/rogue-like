
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


.include "world/world.inc"
.include "actors/actors.inc"
.include "io/gr.inc"
.include "memory.inc"
.include "math.inc"
.include "monitor.inc"

; inits display of map
.export Display_Map_Init
; displays the map and reacts to keyboard input
.export Map_Loop
; displays the map
.export Display_Map_Show



.define DBG_DISP_WIDTH   40
.define DBG_DISP_HEIGHT  48

.BSS
Map_x:  .byte     1
Map_y:  .byte     1

.define MAX_Y HEIGHT_WORLD - DBG_DISP_HEIGHT
.define MAX_X WIDTH_WORLD - DBG_DISP_WIDTH

.CODE

.define KEY_UP      $C9
.define KEY_LEFT    $CA
.define KEY_DOWN    $CB
.define KEY_RIGHT   $CC
.define TAB         $89


; ##################### MAP ##################

; Buffer to save the 4 bottom line of gr1
SAVED_GR_L36: .res  40
SAVED_GR_L37: .res  40
SAVED_GR_L38: .res  40
SAVED_GR_L39: .res  40
; The 4 bottom lines of GR1
.define SRC_GR1_L36 $650
.define SRC_GR1_L37 $6D0
.define SRC_GR1_L38 $750
.define SRC_GR1_L39 $7D0

; @brief Displays the map and wait for action: move the view or exit
Map_Loop:

    ; save the 4 last lines of GR1
    ldx #39
    loop_save_gr:
        lda SRC_GR1_L36, X
        sta SAVED_GR_L36, X
        lda SRC_GR1_L37, X
        sta SAVED_GR_L37, X
        lda SRC_GR1_L38, X
        sta SAVED_GR_L38, X
        lda SRC_GR1_L39, X
        sta SAVED_GR_L39, X
        dex
        bne loop_save_gr
    lda SRC_GR1_L36, X
    sta SAVED_GR_L36, X
    lda SRC_GR1_L37, X
    sta SAVED_GR_L37, X
    lda SRC_GR1_L38, X
    sta SAVED_GR_L38, X
    lda SRC_GR1_L39, X
    sta SAVED_GR_L39, X

disp:
    ; display map
    ;sta $C051   ; full screen
    sta $C054   ; page 1
    sta $C056   ; lores
    sta $C050   ; gfx
    sta $C052   ; mixed mode off

    ldx Map_x
    ldy Map_y
    ; capping X and Y
min_x:
    cpx #$FF
    bne max_x
    ldx #0
    bvc min_y
max_x:
    cpx #MAX_X
    bcc min_y
    ldx #MAX_X
min_y:
    cpy #$FF
    bne max_y
    ldy #0
    bvc disp_map
max_y:
    cpy #MAX_Y
    bcc disp_map
    ldy #MAX_Y
disp_map:
    stx Map_x
    sty Map_y
    jsr Display_Map_Show

    ; waiting for a key to be pressed
kbd_loop:
        lda KEYBD
        bpl kbd_loop  ; bit #8 is set when a character is present (thus A < 0)
    sta KEYBD_STROBE

    cmp #KEY_UP
    beq move_up
    cmp #KEY_RIGHT
    beq move_right
    cmp #KEY_DOWN
    beq move_down
    cmp #KEY_LEFT
    beq move_left
    cmp #TAB
    beq quit
    jmp kbd_loop

move_up:
    dec Map_y
    jmp disp
move_right:
    inc Map_x
    jmp disp
move_down:
    inc Map_y
    jmp disp
move_left:
    dec Map_x
    jmp disp
quit:
    ; restore player's view
    ;sta $C054   ; page 1
    sta $C057   ; hires
    sta $C053   ; mixed mode on

    ; restore the 4 last lines of GR1
    ldx #39
    loop_restore_gr:        
        lda SAVED_GR_L36, X
        sta SRC_GR1_L36, X
        lda SAVED_GR_L37, X
        sta SRC_GR1_L37, X
        lda SAVED_GR_L38, X
        sta SRC_GR1_L38, X
        lda SAVED_GR_L39, X
        sta SRC_GR1_L39, X        
        dex
        bne loop_restore_gr
    lda SAVED_GR_L36, X
    sta SRC_GR1_L36, X
    lda SAVED_GR_L37, X
    sta SRC_GR1_L37, X
    lda SAVED_GR_L38, X
    sta SRC_GR1_L38, X
    lda SAVED_GR_L39, X
    sta SRC_GR1_L39, X
    
    rts



 Display_Map_Init:
    ; Init coords to view map
    lda #0
    sta Map_x
    sta Map_y    

    jsr Clear_Gr1       

    ; display GR1
    sta $C051   ; full screen
    sta $C054   ; page 1
    sta $C056   ; lores
    sta $C050   ; gfx
    sta $C052   ; mixed mode off

    rts

.import World
.define SRC_LINE_UP   ZERO_7_1
.define SRC_LINE_DOWN ZERO_8_1
.define SRC_OFFSET    ZERO_5_5
.define DST_GR1       ZERO_5_5
.define CPT_FILL      ZERO_5_4
.define TMP           ZERO_9_10

Addr_GR1: ; 3 address blocks to fill GR1 (address -1), stored in reversed endianess.
    .word $4F04, $2704, $FF03


; @brief Displays the map in GR1 screen
; @param X top-left x coordinate
; @param Y top-left y coordinate
; X, Y capped by WITH_WOLRD - GR_WIDTH, HEIGHT_WORLD - GR_HEIGHT
; The code in "copy_8x2_lines" copies 16 lines from World 
; It is called 3 times to fill the entire screen. Each line
; is two tile heigh.
 Display_Map_Show:

    ; display GR1
    sta $C051   ; full screen
    sta $C054   ; page 1
    sta $C056   ; lores
    sta $C050   ; gfx
    sta $C052   ; mixed mode off

ld_src:
    ; compute offset
    stx TMP
    sty FAC1
    lda #WIDTH_WORLD
    sta FAC2
    jsr mul8
    sta SRC_OFFSET+1
    txa
    clc
    adc TMP
    sta SRC_OFFSET
    lda SRC_OFFSET+1
    adc #0
    sta SRC_OFFSET+1

    ; source address in World
    lda #<(World-1)
    clc
    adc SRC_OFFSET
    sta SRC_LINE_UP
    lda #>(World-1)
    adc SRC_OFFSET+1
    sta SRC_LINE_UP+1    
    lda SRC_LINE_UP
    clc
    adc #WIDTH_WORLD
    sta SRC_LINE_DOWN
    lda SRC_LINE_UP+1
    adc #0
    sta SRC_LINE_DOWN+1

    ldx #5
    stx CPT_FILL

    ; destination adress in GR1.
    lda Addr_GR1,X
    sta DST_GR1
    dex
    lda Addr_GR1,X
    sta DST_GR1+1
    dex
    stx CPT_FILL

fill:
    ldx #8
copy_8x2_lines: ; call 3 times to fill the screen
    ldy #DBG_DISP_WIDTH
    copy_2_lines:
        lda (SRC_LINE_DOWN),Y
        cmp #eACTORTYPES::FIRST_DYNAMIC
        bcc keep_color_1
        lda #$F ; white
    keep_color_1:
        asl 
        asl 
        asl 
        asl
        sta TMP
        lda (SRC_LINE_UP),Y
        cmp #eACTORTYPES::FIRST_DYNAMIC
        bcc keep_color_2
        lda #$F ; white
    keep_color_2:
        and #$F
        ora TMP    
        sta (DST_GR1), Y
        dey 
        bne copy_2_lines

    ; update source
    lda SRC_LINE_UP
    clc
    adc #(2*WIDTH_WORLD)
    sta SRC_LINE_UP
    lda SRC_LINE_UP+1
    adc #0
    sta SRC_LINE_UP+1
    lda SRC_LINE_DOWN
    clc
    adc #(2*WIDTH_WORLD)
    sta SRC_LINE_DOWN
    lda SRC_LINE_DOWN+1
    adc #0
    sta SRC_LINE_DOWN+1
    ; update destination
    clc
    lda DST_GR1
    adc #$80
    sta DST_GR1
    lda DST_GR1+1
    adc #0
    sta DST_GR1+1
    dex
    bne copy_8x2_lines

    ; destination adress in GR1.
    ldx CPT_FILL
    lda Addr_GR1,X
    sta DST_GR1
    dex
    lda Addr_GR1,X
    sta DST_GR1+1
    dex
    stx CPT_FILL

    cpx #$FD
    bne fill

    rts    
