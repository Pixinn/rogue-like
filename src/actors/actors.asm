.include "../common.inc"
.include "../random.inc"
.include "../memory.inc"
.include "../math.inc"
.include "../world/world.inc"
.include "actors.inc"

.import Rooms
.import World
.import Compute_Maze_Addr

.export ActorsInLevel
.export ActorPositions
.export ActorStates
.export ActorTypes
.export ActorTransparent


.BSS

; struc actors_t {
    .align 256
ActorsInLevel:
    ; aligned 256
    ActorPositions: .res 256      ; coords_t positions[NB_ACTORS_MAX];
    ; aligned 256
    ActorStates:    .res 256      ; actor_state_t* states[NB_ACTORS_MAX];
    ; aligned 256
    ActorTypes:     .res 128      ; uint8_t types[NB_ACTORS_MAX];
; }
; NOTE: Modify SIZEOF_ACTORS_T if necessary!!

.RODATA

.align 256
ActorTransparent:  ; NB_ACTORS_MAX  
; player
.byte TRUE
; floors
.byte TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
; walls
.byte FALSE, FALSE, FALSE, FALSE
; stair down
.byte TRUE
; stair up
.byte FALSE
; monsters
.byte TRUE, TRUE, TRUE
; others
.byte TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
.byte TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
.byte TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
.byte TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
.byte TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
.byte TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
.byte TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE

.CODE

; code
.export Place_Actors
.export Actors_Init

Actors_Init:

    ; positions
    ldx #(2*NB_ACTORS_MAX - 1)
    lda #UNDEF
loop_actors_pos_init:
    sta ActorPositions, x
    dex
    bne loop_actors_pos_init

    ; types
    ldx #eACTORTYPES::LAST_STATIC
loop_actors_types_init:   
    txa
    sta ActorTypes, X
    dex
    bne loop_actors_types_init    
    ldx #eACTORTYPES::LAST_MONSTER+1
loop_actors_types_init_2:
    txa
    sta ActorTypes, X
    inx
    cpx #eACTORTYPES::NB_ACTORS
    bne loop_actors_types_init_2

    rts



.define PTR_ROOM ZERO_2_1 ; 2 bytes
.define PTR_TILE ZERO_2_1 ; 2 bytes
; the two following defines must be the same as in Build_Level
.define ROOM_X   ZERO_3
.define ROOM_Y   ZERO_2_4
.define ROOM_W   ZERO_2_5
.define ROOM_H   ZERO_2_6

; parameters:
.define NB_ROOMS ZERO_9_9
.define ACTOR_ID ZERO_9_1
.define ACTOR_TYPE ZERO_9_2
Place_Actors:

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
    cmp #eACTORTYPES::FLOOR_2
    bne loop_find_location

    ; save position
    ldx ACTOR_ID       
    lda ROOM_X
    sta ActorPositions, X
    lda ROOM_Y
    sta ActorPositions+1, X
    ; save type
    lda ACTOR_TYPE
    sta ActorTypes, X

    txa
    sta (PTR_TILE), Y

    rts