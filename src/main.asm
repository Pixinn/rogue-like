
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

.include "random.inc"
.include "memory.inc"
.include "monitor.inc"

.export _main

.import world_init
.import player_init
.import view_init
.import game_loop

.CODE

_main:
   
    ; init the seed of rnd
    lda #$DE
    sta SEED0
    lda #$AD
    sta SEED1
    lda #$BE
    sta SEED2
    lda #$EF
    sta SEED3

    jsr player_init
    jsr world_init
    jsr view_init
      
    jsr game_loop
    

    rts
