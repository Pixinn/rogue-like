; Copyright (C) 2021 Christophe Meneboeuf <christophe@xtof.info>
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



.import levels_init
.import level_enter     ; param: A = level_nr
.import level_exit
.import level_get_config_offset

.import CurrentLevel
.import NextLevel
.import ExitLevel
.import LevelConfigs
.import NbLevels

.enum LEVELSIZE
  TINY = 20
  SMALL = 24
  NORMAL = 32
  BIG = 48
  HUGE = 64
.endenum


; struct Level
; {
;   uint8_t is_built;       
;   uint8_t seed[4];                    //< seed used to build the level
;   coords_t pos_player_enter;        //< position of player when entering the level (x,y)
; }
;

; nb_levels   >>>> ALWAYS OFFSET + 1!!! <<<<
; array [
    ; struct LevelsConf
    ; {
        ; uint8_t level_nr;
        ; uint8_t size;                       //< eLEVELSIZE
        ; uint8_t actors[NB_ACTORS_MAX];      //< number of actors of each kind added in the level after building the maze
    ; }
; ]

