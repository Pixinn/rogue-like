; Copyright (C) 2020 Christophe Meneboeuf <christophe@xtof.info>
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

.include "actors.inc"
.include "../world/level.inc"
.include "../io/textio.inc"
.include "../common.inc"

.export Reactions_lsb
.export Reactions_msb
.export ReactionStairUp
.export ReactionStairDown
.export ReactionMap

.import ActorPositions
.import World_PickedObject

.DATA

STR_REACTION_WALL:         ASCIIZ "YOU HIT A WALL"
STR_REACTION_STAIR_UP:     ASCIIZ "YOU GO UPSTAIRS TO TO THE NEXT LEVEL"
STR_REACTION_STAIR_DOWN:   ASCIIZ "YOU GO DOWNSTAIRS THE PREVIOUS LEVEL"
STR_REACTION_MAP:          ASCIIZ "YOU FOUND A MAP!"
STR_REACTION_RAT:         ASCIIZ "YOU ATTACK THE RAT"
STR_REACTION_SPIDER:      ASCIIZ "YOU ATTACK THE SPIDER"
STR_REACTION_SERPENT:     ASCIIZ "YOU ATTACK THE SERPENT"

.align 256

; functions address seperated in LSB / MSB to use the same X/Y offset
; They must be in the very same order as the actor's types
Reactions_lsb:
; player
.byte 0
; floors
.byte <ReactionFloor, <ReactionFloor, <ReactionFloor, <ReactionFloor, <ReactionFloor, <ReactionFloor
; walls
.byte <ReactionWall, <ReactionWall, <ReactionWall, <ReactionWall
; stairs
.byte <ReactionStairDown, <ReactionStairUp
; items
.byte <ReactionMap
; monsters
 .byte <ReactionRat, <ReactionSpider, <ReactionSerpent
 ; other
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0

Reactions_msb:
; player
.byte 0
; floors
.byte >ReactionFloor, >ReactionFloor, >ReactionFloor, >ReactionFloor, >ReactionFloor, >ReactionFloor
; walls
.byte >ReactionWall, >ReactionWall, >ReactionWall, >ReactionWall
; stairs
.byte >ReactionStairDown, >ReactionStairUp
; items
.byte >ReactionMap
; monsters
.byte >ReactionRat, >ReactionSpider, >ReactionSerpent
 ; others
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0


.CODE


ReactionFloor:
    lda #TRUE
    rts

ReactionWall:
    PRINT STR_REACTION_WALL
    lda #FALSE
    rts

ReactionStairUp:
    PRINT STR_REACTION_STAIR_UP
    lda CurrentLevel
    sta NextLevel
    inc NextLevel
    lda #TRUE
    sta ExitLevel
    lda #FALSE
    rts

ReactionStairDown:
    PRINT STR_REACTION_STAIR_DOWN
    lda CurrentLevel
    sta NextLevel
    dec NextLevel
    lda #TRUE
    sta ExitLevel
    lda #FALSE
    rts

; @param actor_id in X
ReactionMap:  

    ; index of &ActorPositions[actor_id]
    txa
    asl
    tax
    lda #UNDEF
    sta ActorPositions, X
    sta ActorPositions+1, X

    PRINT STR_REACTION_MAP

    lda #TRUE
    sta World_PickedObject
    
    rts

ReactionRat:
    PRINT STR_REACTION_RAT
    lda #FALSE
    rts

ReactionSpider:
    PRINT STR_REACTION_SPIDER
    lda #FALSE
    rts

ReactionSerpent:
    PRINT STR_REACTION_SERPENT
    lda #FALSE
    rts
