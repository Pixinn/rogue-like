
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
STAIR_DOWN:
.byte $55, $2A, $55, $2A
.byte $11, $00, $40, $00
.byte $71, $7F, $7F, $1F
.byte $71, $01, $C5, $82
.byte $71, $79, $80, $8A
.byte $71, $79, $3C, $00
.byte $71, $79, $3C, $1E
.byte $71, $79, $3C, $1E
.byte $71, $79, $3C, $1E
.byte $71, $79, $3C, $1E
.byte $71, $79, $3C, $1E
.byte $71, $79, $3C, $1E
.byte $71, $79, $3C, $1E
.byte $71, $79, $3C, $1E
.byte $71, $7F, $7F, $1F
.byte $01, $8A, $95, $A8
STAIR_UP:
.byte $55, $2A, $55, $2A
.byte $01, $00, $90, $F8
.byte $01, $AA, $70, $79
.byte $01, $E2, $73, $79
.byte $01, $60, $73, $79
.byte $41, $67, $73, $79
.byte $41, $67, $73, $79
.byte $41, $67, $73, $79
.byte $41, $67, $73, $79
.byte $41, $67, $73, $79
.byte $40, $67, $73, $79
.byte $40, $67, $73, $79
.byte $40, $67, $73, $79
.byte $40, $67, $F3, $A1
.byte $40, $67, $D3, $A8
.byte $C0, $A7, $91, $A8
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
COFFER:
.byte $55, $2A, $55, $2A
.byte $01, $20, $00, $00
.byte $01, $7E, $0F, $00
.byte $41, $67, $3C, $00
.byte $31, $66, $4C, $01
.byte $31, $66, $4C, $01
.byte $31, $66, $4C, $01
.byte $71, $7F, $7F, $01
.byte $31, $C0, $40, $01
.byte $35, $C0, $40, $2B
.byte $B0, $C0, $40, $01
.byte $30, $00, $40, $01
.byte $30, $00, $40, $01
.byte $70, $7F, $7F, $01
.byte $70, $7F, $7F, $01
.byte $10, $00, $40, $00
RAT:
.byte $55, $2A, $55, $2A
.byte $01, $20, $03, $00
.byte $01, $20, $EF, $81
.byte $01, $20, $7C, $1F
.byte $01, $78, $7F, $1F
.byte $01, $7E, $BF, $85
.byte $41, $7F, $0F, $00
.byte $71, $7F, $03, $00
.byte $7D, $7F, $03, $00
.byte $5D, $7F, $57, $2A
.byte $5C, $1F, $43, $00
.byte $5C, $01, $43, $00
.byte $50, $01, $4F, $00
.byte $50, $1F, $40, $00
.byte $10, $00, $40, $00
.byte $10, $00, $40, $00
SERPENT:
.byte $55, $2A, $55, $2A
.byte $01, $20, $03, $00
.byte $01, $60, $0C, $00
.byte $01, $60, $3F, $00
.byte $01, $60, $8B, $80
.byte $01, $60, $A3, $81
.byte $01, $60, $00, $00
.byte $01, $78, $00, $00
.byte $01, $7E, $00, $00
.byte $55, $2F, $55, $2A
.byte $70, $01, $40, $00
.byte $30, $18, $40, $00
.byte $30, $78, $40, $00
.byte $30, $60, $40, $00
.byte $70, $79, $40, $00
.byte $40, $1F, $40, $00
SPIDER:
.byte $55, $2A, $55, $2A
.byte $01, $18, $03, $00
.byte $01, $60, $00, $00
.byte $01, $78, $03, $00
.byte $01, $78, $03, $00
.byte $01, $60, $00, $00
.byte $01, $78, $03, $00
.byte $71, $5F, $7F, $01
.byte $01, $5E, $0F, $00
.byte $75, $5F, $7F, $2B
.byte $10, $56, $0E, $00
.byte $70, $5F, $7F, $01
.byte $10, $58, $43, $00
.byte $50, $7F, $7F, $00
.byte $10, $60, $40, $00
.byte $10, $00, $40, $00
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

; Tiles used by ACTORS
; 128 addresses
TILES:
.word PLAYER
; floors
.word FLOOR_1, FLOOR_2, FLOOR_3, FLOOR_4, FLOOR_4, FLOOR_4
; walls
.word WALL_1, WALL_2, WALL_2, WALL_2
; stairs
.word STAIR_DOWN, STAIR_UP
; items
.word COFFER
; monsters
.word RAT, SPIDER, SERPENT
; other
; COMPLETE TO GET THE 128 TILES!!!
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
.word UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN
