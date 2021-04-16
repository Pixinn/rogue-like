; Copyright (C) 2018-2021 Christophe Meneboeuf <christophe@xtof.info>
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




; The world contains a Maze, filled with Actors
; Actors can be static, such a a floor or a wall,
; dynamic such as a door
; or alive, such as a monster


.define MAXIMUM_WIDTH_MAZE 64   ; must be a power of 2
.define MAXIMUM_HEIGHT_MAZE 64  ; must be a power of 2
.define WIDTH_WORLD  64
.define NEG_WIDTH_WORLD $C0
.define HEIGHT_WORLD 64
.define NEG_HEIGHT_WORLD 64 $C0


.enum ACTORS 

    PLAYER = 0
    
    FLOOR_1 = 1
    FLOOR_2            ; FLOOR BY DEFAULT
    FLOOR_3
    FLOOR_4
    FLOOR_5
    FLOOR_6
    STAIR_DOWN
    STAIR_UP
    WALKABLE = STAIR_UP ; Player won't be allowed to go on anything > WALKABLE
    
    NOT_TRANSPARENT = STAIR_UP
    NOT_WALKABLE    
    
    WALL_1  = NOT_WALKABLE
    WALL_2
    
    UNKNOWN

    NB_ACTORS

.endenum
