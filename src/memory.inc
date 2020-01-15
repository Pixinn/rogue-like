
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


; ********* ZERO PAGE *********
; Free locations in Zero Page: not used by either
; the Monitor, Applesoft, Integer Basic, DOS3.3 or PRODOS

; reserved locations
.define RESERVED01 $52

; locations for the random generator
; little endian
.define SEED0    $6
.define SEED1    $7
.define SEED2    $8
.define SEED3    $9

.define ZERO_2_1    $19
.define ZERO_2_2    $1A
.define ZERO_2_3    $1B
.define ZERO_2_4    $1C
.define ZERO_2_5    $1D
.define ZERO_2_6    $1E

.define ZERO_3      $E3

.define ZERO_4_1    $EB
.define ZERO_4_2    $EC
.define ZERO_4_3    $ED
.define ZERO_4_4    $EE
.define ZERO_4_5    $EF

.define ZERO_5_1    $FA
.define ZERO_5_2    $FB
.define ZERO_5_3    $FC
.define ZERO_5_4    $FD
.define ZERO_5_5    $FE
.define ZERO_5_6    $FF

; Used by Integer Basic

.define ZERO_7_1    $CE 
.define ZERO_7_2    $CF

.define ZERO_8_1    $D6 
.define ZERO_8_2    $D7 

; ************ I/O ************
.define KEYBD           $C000
.define KEYBD_STROBE    $C010

; *********** HIRES ************
.define ADDR_HGR1   $2000
.define ADDR_HGR2   $4000

; ********** TEXT *************
.define TXT1_LINE0      $400
.define TXT1_LINE1      $480
.define TXT1_LINE2      $500
.define TXT1_LINE3      $580
.define TXT1_LINE4      $600
.define TXT1_LINE5      $680
.define TXT1_LINE6      $700
.define TXT1_LINE7      $780
.define TXT1_LINE8      $428
.define TXT1_LINE9      $4A8
.define TXT1_LINE10     $528
.define TXT1_LINE11     $5A8
.define TXT1_LINE12     $628
.define TXT1_LINE13     $6A8
.define TXT1_LINE14     $728
.define TXT1_LINE15     $7A8
.define TXT1_LINE16     $450
.define TXT1_LINE17     $4D0
.define TXT1_LINE18     $550
.define TXT1_LINE19     $5D0
.define TXT1_LINE20     $650
.define TXT1_LINE21     $6D0
.define TXT1_LINE22     $750
.define TXT1_LINE23     $7D0

.import TXT1_LINES


; *********** CUSTOM ROUTINES *********
.define FROM     ZERO_2_1   ; 2 bytes
.define TO       ZERO_2_3   ; 2 bytes
.define SIZEH    ZERO_8_1
.define SIZEL    ZERO_8_2
.import memcpy


; ************ MACROS ***********

; pushes addr to the stack
; A is detroyed
.macro PUSH addr
    lda addr
    pha
.endmacro


; pops addr from the stack
; A is detroyed
.macro POP addr
    pla
    sta addr
.endmacro