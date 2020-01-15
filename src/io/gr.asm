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


.export Clear_Gr1


.CODE

;@brief Clears GR1 screen
; BEWARE : It will fill the "holes" with 0s
Clear_Gr1:

    lda #0      ; black    
    ldx #0
clear_gr1_1:    
    sta $400, X
    inx
    bne clear_gr1_1
    ldx #0
clear_gr1_2:    
    sta $500, X
    inx
    bne clear_gr1_2
    ldx #0
clear_gr1_3:    
    sta $600, X
    inx
    bne clear_gr1_3
    ldx #0
clear_gr1_4:
    sta $700, X
    inx
    bne clear_gr1_4   

    rts