
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


; ********* ZERO PAGE *********
; Free locations in Zero Page: not used by either
; the Monitor, Applesoft, Integer Basic, DOS3.3 or PRODOS

; locations for the random generator
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