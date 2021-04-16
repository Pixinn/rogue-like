.include "../common.inc"
.include "../random.inc"
.include "../memory.inc"
.include "../math.inc"
.include "../world/world.inc"
.include "actors_private.inc"

.import Rooms
.import World
.import Compute_Maze_Addr

; code
.export Place_Actors
; data
.export ActiveActor_Tiles

.DATA

ActiveActor_Tiles:  .byte ACTORS::STAIR_UP, ACTORS::STAIR_DOWN, ACTORS::FLOOR_1 ; DEBUg: placeholder for future map
.CODE

.define PTR_ROOM ZERO_2_1 ; 2 bytes
.define PTR_TILE ZERO_2_1 ; 2 bytes
; the two following defines must be the same as in Build_Level
.define ROOM_X   ZERO_3
.define ROOM_Y   ZERO_2_4
.define ROOM_W   ZERO_2_5
.define ROOM_H   ZERO_2_6
.define NB_ROOMS ZERO_9_9
.define ACTOR    ZERO_9_10
; A : ACTOR
; X : NB_ROOMS
Place_Actors:

    sta ACTOR
    stx NB_ROOMS

loop_find_location:    

    jsr Random8
    ldx NB_ROOMS
    jsr Modulus

    ; sizeof(room_t) == 4
    asl
    asl
    clc
    adc #<Rooms
    sta PTR_ROOM
    lda #0
    adc #>Rooms
    sta PTR_ROOM+1

    ldy #0
    lda (PTR_ROOM), Y
    sta ROOM_H
    iny
    lda (PTR_ROOM), Y
    sta ROOM_W
    iny
    lda (PTR_ROOM), Y
    sta ROOM_X
    iny
    lda (PTR_ROOM), Y
    sta ROOM_Y

    ; x = room->x + rand() % (room->width - 2) + 1;    
    sec
    lda ROOM_W
    sbc #2
    sta ROOM_W
    jsr Random8
    ldx ROOM_W
    jsr Modulus
    clc
    adc ROOM_X
    adc #1
    sta ROOM_X

    ; y = room->y + rand() % (room->height - 2) + 1;    
    sec
    lda ROOM_H
    sbc #2
    sta ROOM_H
    jsr Random8
    ldx ROOM_H
    jsr Modulus
    clc
    adc ROOM_Y
    adc #1
    sta ROOM_Y
    tay

    ldx ROOM_X    
    jsr Compute_Maze_Addr
    stx PTR_TILE
    sta PTR_TILE+1
    ldy #0
    lda (PTR_TILE), Y
    cmp #ACTORS::FLOOR_2
    bne loop_find_location


    lda ACTOR
    sta (PTR_TILE), Y

    rts