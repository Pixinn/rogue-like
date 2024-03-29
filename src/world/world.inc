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
.define NEG_HEIGHT_WORLD $C0

