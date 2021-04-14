
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



.include "rooms.inc"
.include "maze.inc"
.include "../io/textio.inc"
.include "../memory.inc"
.include "../math.inc"
.include "../common.inc"
.include "../world/world.inc"

.import World
.import Rooms
.import WIDTH_MAZE
.import HEIGHT_MAZE

.import Compute_Maze_Addr

.export Unite_Rooms

.BSS

.DATA 

.CODE


.define PTR_TILE  ZERO_2_1 ; 2 bytes
.define ZONE_NR   ZERO_2_4
.define CPT_X     ZERO_2_5
.define CPT_Y     ZERO_2_6


.define QUEUE_ADDR $4000


.define REPLACED_NR     ZERO_3
.define PTR_QUEUE       ZERO_4_1 ; 2 bytes
.define PTR_TILE_LOCAL  ZERO_4_3 ; 2 bytes
.define FILL_NR         ZERO_4_5
; @param X fill color
; @param A replaced
; @return TRUE in A some tiles were filled, FALSE otherwise
_Flood_Fill :
    
    stx FILL_NR
    ldy #0
    cmp (PTR_TILE), Y   ; if (*ptr_tile != replaced) return;
    beq fill_1
    lda FALSE
    rts

fill_1:
    sta REPLACED_NR
    txa
    sta (PTR_TILE), Y
    lda #<QUEUE_ADDR
    sta PTR_QUEUE
    lda #>QUEUE_ADDR
    sta PTR_QUEUE+1
    ; offset ptr_tile by -width_world to be quickly accessed with an Y offset
    lda PTR_TILE
    sec
    sbc #WIDTH_WORLD
    sta QUEUE_ADDR
    lda PTR_TILE+1
    sbc #0
    sta QUEUE_ADDR+1
    
    ldx #0
    loop_fill:

        ; while ptr_queue >= QUEUE_ADDR  
        lda PTR_QUEUE
        cmp #<(QUEUE_ADDR-2)
        bne continue_fill
        lda PTR_QUEUE+1
        cmp #>(QUEUE_ADDR-2)
        bne continue_fill
        jmp end_fill

        continue_fill:
        ;  ptr_tile = *(ptr_queue--);
        ldy #0
        lda (PTR_QUEUE), Y 
        sta PTR_TILE_LOCAL
        iny
        lda (PTR_QUEUE), Y
        sta PTR_TILE_LOCAL+1
        DEC16 PTR_QUEUE, #2

        tile_west:
        ; if (*tile_west == replaced)
        ldy #(WIDTH_WORLD+1)
        lda REPLACED_NR
        cmp (PTR_TILE_LOCAL),Y
        bne tile_east
        ; *tile_west = fill;
        lda FILL_NR
        sta (PTR_TILE_LOCAL),Y
        ; *(++ptr_queue) = tile_w
        ADD16 PTR_QUEUE, #2
        clc
        lda #1
        adc PTR_TILE_LOCAL
        ldy #0
        sta (PTR_QUEUE),Y
        lda #0
        adc PTR_TILE_LOCAL+1
        iny
        sta (PTR_QUEUE),Y
        

        tile_east:
        ; if (*tile_east == replaced)
        ldy #(WIDTH_WORLD-1)
        lda REPLACED_NR
        cmp (PTR_TILE_LOCAL),Y
        bne tile_north
        ; *tile_east = fill;
        lda FILL_NR
        sta (PTR_TILE_LOCAL),Y
        ; *(++ptr_queue) = tile_tile_east
        ADD16 PTR_QUEUE, #2
        sec
        lda PTR_TILE_LOCAL
        sbc #1 
        ldy #0
        sta (PTR_QUEUE),Y
        lda PTR_TILE_LOCAL+1
        sbc #0
        iny
        sta (PTR_QUEUE),Y

        tile_north:
        ; if (*tile_north == replaced)
        ldy #0
        lda REPLACED_NR
        cmp (PTR_TILE_LOCAL),Y
        bne tile_south
        ; *tile_north = fill;
        lda FILL_NR
        sta (PTR_TILE_LOCAL),Y
        ; *(++ptr_queue) = tile_tile_north
        ADD16 PTR_QUEUE, #2
        sec
        lda PTR_TILE_LOCAL
        sbc #WIDTH_WORLD
        ldy #0
        sta (PTR_QUEUE),Y
        lda PTR_TILE_LOCAL+1
        sbc #0
        iny
        sta (PTR_QUEUE),Y

        tile_south:
        ; if (*tile_south == replaced)
        ldy #(2*WIDTH_WORLD)
        lda REPLACED_NR
        cmp (PTR_TILE_LOCAL),Y
        bne end_tiles
        ; *tile_south = fill;
        lda FILL_NR
        sta (PTR_TILE_LOCAL),Y
        ; *(++ptr_queue) = tile_tile_south
        ADD16 PTR_QUEUE, #2
        clc
        lda #WIDTH_WORLD
        adc PTR_TILE_LOCAL
        ldy #0
        sta (PTR_QUEUE),Y
        lda #0
        adc PTR_TILE_LOCAL+1
        iny
        sta (PTR_QUEUE),Y

        end_tiles:
        jmp loop_fill


end_fill:
    lda TRUE
    rts



.define ROOM_NR  ZERO_3
.define SAVE_X   ZERO_4_1
.define PTR_ROOM ZERO_4_2               ; 2 bytes
.define ZONE_0   ACTORS::FLOOR_1        ; 1st useful zone: ZONE_1
Unite_Rooms:

    ; *** flood fill room to identify separated zones ***
    ; &Wordl[1][1] -> ptr_tile
    clc
    lda #<World
    adc #WIDTH_WORLD+1     
    sta PTR_TILE
    lda #>World
    adc #0
    sta PTR_TILE+1
    lda #1
    sta CPT_X
    sta CPT_Y

    lda #ZONE_0
    sta ZONE_NR
    inc ZONE_NR

    loop_flood:
        ldx ZONE_NR
        lda #ZONE_0
        jsr _Flood_Fill
        cmp TRUE
        bne loop_flood_next
        inc ZONE_NR

    loop_flood_next:
        ;next tile
        ADD16 PTR_TILE, #1
        ; end line?
        inc CPT_X
        ldx CPT_X
        cpx #WIDTH_WORLD-1
        bne loop_flood
        ldx #0
        stx CPT_X
        ; next
        ADD16 PTR_TILE, #1
        ; the end?
        inc CPT_Y
        ldy CPT_Y
        cpy #HEIGHT_WORLD-1
        bne loop_flood

    ; *** 
    ; reunite rooms that are not in the first zone
    ; find the location of a room in zone_1
    ; Its origin will be targeted by th other zones to join
    ; ***
    .define SIZEOF_ROOM_T   4
    .define ROOM_ZONE_1     ZERO_5_4
    lda #0          ; FIXEME : useless?
    sta ROOM_NR     ; FIXEME : useless?
    ldx #3
    lda #WIDTH_WORLD
    sta FAC2
    loop_find_room:        
        lda Rooms, X
        tay        
        stx SAVE_X
        dex
        lda Rooms, X 
        tax
        jsr Compute_Maze_Addr
        sta PTR_TILE+1
        stx PTR_TILE
        ldy #0
        lda (PTR_TILE), Y
        cmp #(ZONE_0 + 1)
        beq room_found
        ; next room
        lda SAVE_X
        clc
        adc #(SIZEOF_ROOM_T)
        tax
        jmp loop_find_room

    room_found:
        ldx SAVE_X
        stx ROOM_ZONE_1

    ; ***
    ; Connect one room of each zone to the location found
    .define END_LOOP_ZONE ZERO_5_1
    lda ZONE_NR
    sta END_LOOP_ZONE
    lda #(ZONE_0 + 2)  ; zone_2
    cmp END_LOOP_ZONE
    beq end_loop_zone  ; only one zone
    sta ZONE_NR
    
    ; loop over the zones     
    loop_zones:
        
        ldx #3        
        loop_rooms: ; find a room of the zone
            lda Rooms, X
            tay
            stx SAVE_X
            dex            
            lda Rooms, X 
            tax
            jsr Compute_Maze_Addr
            stx ZERO_5_2
            sta ZERO_5_3
            ldy #0
            lda (ZERO_5_2), Y
            cmp ZONE_NR
            beq zone_found
            ; next room
            lda SAVE_X
            clc
            adc #(SIZEOF_ROOM_T)
            tax
            jmp loop_rooms
    
        zone_found:
        jsr _Connect_Room
        ; next zone
        inc ZONE_NR
        ; end loop?
        lda END_LOOP_ZONE
        cmp ZONE_NR
        beq end_loop_zone
        ; loop
        jmp loop_zones
    
    end_loop_zone:



    rts

; to compute ptr_romm += ix / iy or ptr_romm += ix / iy, the code is patched.
.macro PATCH_POS address, address2 
    lda #$18        ; clc
    sta address
    sta address2
    lda #$69        ; adc imm
    sta address+3   ; adc #1 / #WIDTH_WORLD
    sta address+9   ; adc #0
    sta address2+3  ; adc #1 / #WIDTH_WORLD
    sta address2+9  ; adc #0
.endmacro
.macro PATCH_NEG address, address2 
    lda #$38        ; sec
    sta address
    sta address2
    lda #$E9        ; sbc imm
    sta address+3   ; sbc #1 / #WIDTH_WORLD
    sta address+9   ; sbc #0
    sta address2+3  ; sbc #1 / #WIDTH_WORLD
    sta address2+9  ; sbc #0
.endmacro

.define DELTA_X     ZERO_9_1
.define DELTA_Y     ZERO_9_2
.define DELTA_X_2   ZERO_9_3
.define DELTA_Y_2   ZERO_9_4
.define ROOM_Y      ZERO_9_5
.define ROOM_X      ZERO_9_6
.define D           ZERO_9_7
.define ROOM_FOUND  SAVE_X
_Connect_Room:

    ; d = 0
    lda #0
    sta D
       
    ; delta_y = zone1_y - room->y
    ldx ROOM_FOUND
    lda Rooms, X 
    sta ROOM_Y      ; room->y
    dex
    lda Rooms, X     
    sta ROOM_X      ; room->x
    ldx ROOM_ZONE_1
    lda Rooms, X    ; zone1_y
    sec
    sbc ROOM_Y
    sta DELTA_Y
    ; delta_x = zone1_x - room->x
    dex
    lda Rooms, X     ; zone1_x
    sec
    sbc ROOM_X
    sta DELTA_X

    ; delta_x = delta_x > 0 ? delta_x : -delta_x
    lda #0
    cmp DELTA_X
    bmi end_abs_x
    sec
    sbc DELTA_X
    sta DELTA_X
    end_abs_x:
    ; int dx2 = 2 * dx
    lda DELTA_X
    asl 
    sta DELTA_X_2

    ; delta_y = delta_y > 0 ? delta_y : -delta_y
    abs_delta_y:
    lda #0
    cmp DELTA_Y
    bmi end_abs_y
    sec
    sbc DELTA_Y
    sta DELTA_Y
    end_abs_y:
    ;  int dy2 = 2 * dy
    lda DELTA_Y
    asl 
    sta DELTA_Y_2

    ; uint8_t* ptr_room = &World[room->y][room->x]
    ldx ROOM_X
    ldy ROOM_Y
    jsr Compute_Maze_Addr
    stx PTR_ROOM
    stx PTR_TILE
    sta PTR_ROOM+1
    sta PTR_TILE+1
    
    ldx ROOM_ZONE_1
    dex
    ; int ix = room->x < zone1_x ? 1 : -1
    ix:
    lda ROOM_X
    cmp Rooms, X    
    bcc ix_positive
    PATCH_NEG patch_ix1, patch_ix2
    jmp iy
    ix_positive:
    PATCH_POS patch_ix1, patch_ix2
    ; int iy = room->y < zone1_y ? WIDTH_WORLD : -WIDTH_WORLD;
    iy:
    inx
    lda ROOM_Y
    cmp Rooms, X     
    bcc iy_positive
    PATCH_NEG patch_iy1, patch_iy2
    jmp iterate
    iy_positive:
    PATCH_POS patch_iy1, patch_iy2  

    iterate:    
    ldy #0
    lda DELTA_X
    cmp DELTA_Y
    bcc dy_sup
    ; if (dx >= dy)
    dx_sup:
        while_1:
            ; ptr_room += ix
            patch_ix1:
            ADD16 PTR_ROOM, #1
            ; d += dy2
            clc
            lda DELTA_Y_2
            adc D
            sta D
            cmp DELTA_X
            bcc d_infequal_dx
            beq d_infequal_dx
                ; if (d > dx)
                ; if (*ptr_room != zone_nr && *ptr_room <= WALKABLE)  break;            
                lda (PTR_ROOM), Y ; Y = 0
                cmp ZONE_NR
                beq continue_1a
                cmp #ACTORS::WALKABLE
                beq end
                bpl continue_1a
                jmp end
                continue_1a:
                ; *ptr_room = zone_nr
                lda ZONE_NR
                sta (PTR_ROOM), Y ; Y = 0
                ; ptr_room += iy
                patch_iy1:
                ADD16 PTR_ROOM, #WIDTH_WORLD
                ; d -= dx2
                sec
                lda D 
                sbc DELTA_X_2
                sta D
            d_infequal_dx:
            ; if (*ptr_room != zone_nr && *ptr_room <= WALKABLE)  break;            
            lda (PTR_ROOM), Y ; Y = 0
            cmp ZONE_NR
            beq continue_1b
            cmp #ACTORS::WALKABLE
            beq end
            bpl continue_1b
            jmp end
            continue_1b:
            lda ZONE_NR
            sta (PTR_ROOM), Y ; Y = 0
            jmp while_1

    ; end label in the middle to be reachable by the branches
    end:

    ; flood fills works on ptr_tile
    ldx #(ZONE_0 + 1)
    lda ZONE_NR
    jsr _Flood_Fill
    rts

    dy_sup:
        while_2:
            ; ptr_room += iy
            patch_iy2:
            ADD16 PTR_ROOM, #WIDTH_WORLD
            ; d += dx2
            clc
            lda DELTA_X_2
            adc D
            sta D
            cmp DELTA_Y
            bcc d_infequal_dy
            beq d_infequal_dy
                ; if (d > dy) {
                ; if (*ptr_room != zone_nr && *ptr_room <= WALKABLE)  break;            
                lda (PTR_ROOM), Y ; Y = 0
                cmp ZONE_NR
                beq continue_2a
                cmp #ACTORS::WALKABLE
                beq end
                bpl continue_2a
                jmp end
                continue_2a:
                ; *ptr_room = zone_nr
                lda ZONE_NR
                sta (PTR_ROOM), Y ; Y = 0
                ; ptr_room += ix;
                patch_ix2:
                ADD16 PTR_ROOM, #1
                ; d -= dy2
                sec
                lda D 
                sbc DELTA_Y_2
                sta D
            d_infequal_dy:
            ; (*ptr_room != zone_nr && *ptr_room <= WALKABLE)
            lda (PTR_ROOM), Y ; Y = 0
            cmp ZONE_NR
            beq continue_2b
            cmp #ACTORS::WALKABLE
            beq end
            bpl continue_2b
            jmp end
            continue_2b:
            lda ZONE_NR
            sta (PTR_ROOM), Y ; Y = 0
            jmp while_2