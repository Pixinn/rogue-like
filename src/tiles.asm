
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

.export TILES

.SEGMENT "RODATA"
.ALIGN 256

PLAYER:
.byte 85, 42, 85, 42
.byte 1, 120, 3, 0
.byte 1, 126, 15, 0
.byte 1, 102, 12, 0
.byte 1, 126, 15, 0
.byte 1, 30, 15, 24
.byte 1, 120, 3, 6
.byte 113, 103, 76, 1
.byte 49, 70, 48, 0
.byte 53, 94, 95, 43
.byte 112, 71, 64, 0
.byte 80, 65, 64, 0
.byte 16, 16, 66, 0
.byte 16, 16, 66, 0
.byte 16, 16, 66, 0
.byte 16, 20, 74, 0
FLOOR_1:
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
.byte $00, $00, $00, $00
FLOOR_2:
.byte 85, 42, 85, 42
.byte 1, 32, 0, 0
.byte 1, 32, 0, 0
.byte 1, 32, 0, 0
.byte 1, 32, 0, 0
.byte 1, 32, 0, 0
.byte 1, 32, 0, 0
.byte 1, 32, 0, 0
.byte 1, 32, 0, 0
.byte 85, 42, 85, 42
.byte 16, 0, 64, 0
.byte 16, 0, 64, 0
.byte 16, 0, 64, 0
.byte 16, 0, 64, 0
.byte 16, 0, 64, 0
.byte 16, 0, 64, 0
FLOOR_3:
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
.byte $55, $2A, $55, $2A
FLOOR_4:
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
.byte $D5, $AA, $D5, $AA
WALL_1:
.byte 197, 138, 213, 168
.byte 197, 138, 213, 168
.byte 197, 138, 213, 168
.byte 0, 0, 0, 0
.byte 209, 162, 149, 170
.byte 209, 162, 149, 170
.byte 209, 162, 149, 170
.byte 209, 162, 149, 170
.byte 0, 0, 0, 0
.byte 213, 168, 197, 138
.byte 213, 168, 197, 138
.byte 213, 168, 197, 138
.byte 0, 0, 0, 0
.byte 209, 130, 213, 168
.byte 209, 138, 212, 168
.byte 0, 0, 0, 0
WALL_2:
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
.byte $7F, $7F, $7F, $7F
UNKNOWN:
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80
.byte $80, $80, $80, $80


.ALIGN 256
; DON"T FORGET TO UPDATE NB_TILES!!
TILES:
.word  PLAYER, FLOOR_1, FLOOR_2, FLOOR_3, FLOOR_4, WALL_1, WALL_2, UNKNOWN
