
; Copyright (C) 2019 Christophe Meneboeuf <christophe@xtof.info>
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

.include "../memory.inc"
.include "../random.inc"
.include "../math.inc"
.include "../common.inc"
.include "../world/world.inc"
.include "../actors/actors.inc"

.export Carve_Rooms
.export Connect_Rooms

.import Rooms
.import Compute_Maze_Addr
.import World
.import WIDTH_MAZE
.import HEIGHT_MAZE


.BSS

; Configration to build rooms
; FIXME??? CA65 will locate this struct at address 0 !!!
.struct Config_Room
    width_min   .byte
    width_max   .byte
    height_min  .byte
    height_max  .byte
.endstruct

.CODE

.define NB_ATTEMPTS ZERO_2_1
.define NB_ROOMS_OK ZERO_2_2
.define NB_ROOMS_TO_DRAW NB_ATTEMPTS
.define IDX_ROOMS ZERO_3

; @params A nb_attempts
; @returns NB_ROOMS_OK in A
Carve_Rooms:

    sta NB_ATTEMPTS

    ; height_max + width_max shall be < 64
    lda #9
    sta Config_Room::height_max
    lda #3
    sta Config_Room::height_min
    lda #11
    sta Config_Room::width_max
    lda #3
    sta Config_Room::width_min

    ldx #0
    stx NB_ROOMS_OK

    loop_rooms:

        dec NB_ATTEMPTS
        beq end_loop_rooms
        lda NB_ROOMS_OK ; NB_ROOMS_OK*sizeof(room_t) -> X
        asl
        asl
        tax        

        jsr _Build_Room

        lda NB_ROOMS_OK
        jsr _Is_intersecting
        cmp #TRUE  ; not intersecting with another room?
        beq loop_rooms
    
        inc NB_ROOMS_OK
        jmp loop_rooms

    end_loop_rooms:

    lda NB_ROOMS_OK
    sta NB_ROOMS_TO_DRAW

    ldx #0
    loop_draw_rooms:

        jsr _Draw_Room
        
        inx
        inx
        inx
        inx
        
        dec NB_ROOMS_TO_DRAW
        bne loop_draw_rooms
        
    end_loop_draw_rooms:

    lda NB_ROOMS_OK    

    rts
.undefine NB_ATTEMPTS
.undefine NB_ROOMS_OK
.undefine NB_ROOMS_TO_DRAW
.undefine IDX_ROOMS


.define ADDR_WORLD  ZERO_2_3 ; 2 bytes
.define NB_LINE     ZERO_2_5
.define LINE_LENGTH ZERO_2_6
.define IDX_ROOMS   ZERO_3
_Draw_Room:

    stx IDX_ROOMS

    ldy Rooms+3, X  ; room->y
    lda Rooms+2, X ; rooms->x
    tax
    PUSH ZERO_2_1
    PUSH ZERO_2_2
    jsr Compute_Maze_Addr
    stx ADDR_WORLD
    sta ADDR_WORLD+1
    POP ZERO_2_2
    POP ZERO_2_1


    ldx IDX_ROOMS
    ldy Rooms, X    ; room->height
    sty NB_LINE
    lda Rooms+1, X    ; room->width
    sta LINE_LENGTH    
    loop_draw_line:
        lda #eACTORTYPES::FLOOR_1
        ldy #0
        loop_draw_tile:
            sta (ADDR_WORLD), Y
            iny
            cpy LINE_LENGTH
            bne loop_draw_tile
        end_loop_draw_tile:
        clc
        lda ADDR_WORLD
        adc #WIDTH_WORLD
        sta ADDR_WORLD
        lda ADDR_WORLD+1
        adc #0
        sta ADDR_WORLD+1
        dec NB_LINE
        bne loop_draw_line
    end_loop_draw_line:

    ldx IDX_ROOMS
    rts
.undefine ADDR_WORLD
.undefine NB_LINE
.undefine LINE_LENGTH
.undefine IDX_ROOMS


.define MODULUS         ZERO_2_3
.define WIDTH_ROOM      ZERO_2_5
.define HEIGHT_ROOM     ZERO_2_6
.define OFFSET_ROOMS    ZERO_5_1
; @param X offset to the room to be built from Rooms
; @return offset room in X
_Build_Room:
        
    stx OFFSET_ROOMS

    ; room.height = config->height_min + Random8() % (config->height_max - config->height_min - 1);
    sec
    lda Config_Room::height_max
    sbc Config_Room::height_min
    sbc #1
    sta MODULUS
    jsr Random8
    and #7
    ldx MODULUS
    jsr Modulus        
    ldx OFFSET_ROOMS
    clc
    adc Config_Room::height_min
    ora #1
    sta Rooms, x    ; height
    sta HEIGHT_ROOM
    inx
    stx OFFSET_ROOMS

    ; room.width = config->width_min + Random8() % (config->width_max - config->width_min - 1);
    sec
    lda Config_Room::width_max
    sbc Config_Room::width_min
    sbc #1
    sta MODULUS
    jsr Random8
    and #$F ; room's height shall be < 16
    ldx MODULUS
    jsr Modulus
    ldx OFFSET_ROOMS
    clc
    adc Config_Room::width_min
    ora #1
    sta Rooms, x    ; width
    sta WIDTH_ROOM
    inx
    stx OFFSET_ROOMS


    ; room.x = 3 + Random8() % (WIDTH_MAZE - room.width - 5);
    sec
    lda WIDTH_MAZE
    sbc WIDTH_ROOM
    sbc #5
    sta MODULUS
    jsr Random8
    and #$7F
    ldx MODULUS
    jsr Modulus
    ldx OFFSET_ROOMS
    clc
    adc #3
    ora #1
    sta Rooms, x     ; x
    inx
    stx OFFSET_ROOMS

    ; room.y = 3 + Random8() % (HEIGHT_MAZE - room.height - 5);
    sec
    lda HEIGHT_MAZE
    sbc HEIGHT_ROOM
    sbc #5
    sta MODULUS
    jsr Random8
    and #$7F
    ldx MODULUS
    jsr Modulus
    ldx OFFSET_ROOMS
    clc
    adc #3
    ora #1
    sta Rooms, x     ; y
    inx
    stx OFFSET_ROOMS

    rts
.undefine MODULUS        
.undefine WIDTH_ROOM     
.undefine HEIGHT_ROOM    
.undefine OFFSET_ROOMS   


; @brief test ifthe room is intersecting with other rooms
; @param A : nb rooms already carved
; @return 0 if no intersection, 1 otherwise
.define NB_ROOMS    ZERO_3
.define OFFSET_Y    ZERO_2_4
.define OFFSET_X    ZERO_2_5
_Is_intersecting:

    cmp #0
    bne compare
    ; first room
    lda #FALSE
    clc
    bcc end_intersecting ; branch always

    ; previous rooms were carved
compare:
    sta NB_ROOMS
    asl         ; * sizeof(room_t) to get offset to the last room randomized
    asl
    tax         ; offset to new room in X
    stx OFFSET_X
    ldy #0      ; offset to carved rooms in Y

    loop_intersecting:  ; each test must be true
        sty OFFSET_Y
        clc
        lda Rooms+2, Y  ; room->x
        adc Rooms+1, Y  ; room->width
        cmp Rooms+2, X 
        bcc false       ; branch if room->x + room->width < new_room->x
        clc      
        lda Rooms+2, X  ; new_room->x
        adc Rooms+1, X  ; new_room->width
        cmp Rooms+2, Y  ; room->x
        bcc false       ; branch if new_room->x + new_room->width < room->x
        clc
        lda Rooms+3, Y  ; room->y
        adc Rooms, Y    ; room->height
        cmp Rooms+3, X  ; new_room->y
        bcc false       ; branch if room->y + room->height < new_room->y
        clc
        lda Rooms+3, X  ; new_room->y
        adc Rooms, X    ; new_room->height
        cmp Rooms+3, Y  ; room->y
        bcc false       ; branch if new_room->y + new_room->height < room->y
        ; all test are true: rooms are intersecting
        lda #TRUE ; return value
        clc
        bcc end_intersecting

    false:
        ldx OFFSET_X
        lda OFFSET_Y
        adc #4
        tay
        dec NB_ROOMS
        bne loop_intersecting

    lda #FALSE ; no room intersects

end_intersecting:
    rts


; using HGR2 space as the stack
; Stack contains pointers to the tiles encompassing a room (except the corners)
.define STACK_ADDR  $4000
.define PTR_TILE_TOP    ZERO_2_3   ; 2 bytes
.define PTR_TILE_BOT    ZERO_4_4   ; 2 bytes
.define PTR_TILE_LEFT   ZERO_2_3   ; 2 bytes
.define PTR_TILE_RIGHT  ZERO_4_4   ; 2 bytes
.define PTR_TILE        ZERO_2_1
.define PTR_STACK       ZERO_4_1      ; 2 bytes
.define PROBABILITY_OPENING ZERO_4_3
.define NB_DOORS        ZERO_5_1
.define NB_WALKABLE     ZERO_5_2
.define SIZE_STACK      ZERO_5_3     ; 2 bytes
.define WIDTH_ROOM      ZERO_2_5
.define HEIGHT_ROOM     ZERO_2_6
.define OFFSET_ROOMS    ZERO_5_5

; @brief Connects the rooms to the maze's galleries
; @param A number of rooms
; @param X probability to make an opening in a wall tile
; @detail One opening is made, then all remaning encompassing wall tiles
;         can be opened. Depending on the provided probability 
Connect_Rooms:

    sta NB_ROOMS
    stx PROBABILITY_OPENING

    lda #0
    sta OFFSET_ROOMS
    ; for each room
    loop_connect_rooms: 

        ; # Build a stack of encompassing tiles. Except corners  
        lda #<STACK_ADDR
        sta PTR_STACK
        lda #>STACK_ADDR
        sta PTR_STACK+1
        
        ; ## stacking horizontal walls
        ; ### init ptr_top        
        ldx OFFSET_ROOMS
        inx
        inx
        lda Rooms, X ; room->x
        sta PTR_TILE_TOP
        clc
        lda #<World
        adc PTR_TILE_TOP
        sta PTR_TILE_TOP
        lda #>World
        adc #0
        sta PTR_TILE_TOP+1
        inx
        lda Rooms, X ; room->y
        tax
        dex
        stx FAC1
        lda #WIDTH_WORLD
        sta FAC2
        jsr mul8
        tay
        txa 
        clc
        adc PTR_TILE_TOP
        sta PTR_TILE_TOP
        tya 
        adc PTR_TILE_TOP+1
        sta PTR_TILE_TOP+1
        
        ; ### init ptr_bottom
        ldx OFFSET_ROOMS
        lda Rooms, X ; room->height
        sta HEIGHT_ROOM
        tax
        inx
        stx FAC1
        lda #WIDTH_WORLD
        sta FAC2
        jsr mul8
        tay
        txa
        clc
        adc PTR_TILE_TOP
        sta PTR_TILE_BOT
        tya
        adc PTR_TILE_TOP+1
        sta PTR_TILE_BOT+1
        
        ; ## stacking
        ldx OFFSET_ROOMS
        inx
        lda Rooms, X ; room->width
        sta WIDTH_ROOM
        ; for x = 0; x < room->width; x++
        ldx #0
        loop_stack_horiz:
            ldy #0
            clc
            txa
            adc PTR_TILE_TOP 
            sta (PTR_STACK), Y
            iny
            lda #0
            adc PTR_TILE_TOP+1
            sta (PTR_STACK), Y
            iny
            txa
            adc PTR_TILE_BOT
            sta (PTR_STACK), Y
            iny
            lda #0
            adc PTR_TILE_BOT+1
            sta (PTR_STACK), Y
            iny
            ; incr ptr_stack
            tya
            clc
            adc PTR_STACK
            sta PTR_STACK
            lda #0
            adc PTR_STACK+1
            sta PTR_STACK+1
            ; next x
            inx
            cpx WIDTH_ROOM
            bne loop_stack_horiz

        ; ## stacking vertical walls
        ; ### init ptr_left
        clc
        lda #(WIDTH_WORLD-1)
        adc PTR_TILE_TOP
        sta PTR_TILE_LEFT
        lda #0
        adc PTR_TILE_TOP+1
        sta PTR_TILE_LEFT+1
        ; ### init ptr_right
        clc
        lda WIDTH_ROOM
        adc #1
        adc PTR_TILE_LEFT
        sta PTR_TILE_RIGHT
        lda #0
        adc PTR_TILE_LEFT+1
        sta PTR_TILE_RIGHT+1
        ; ### stacking
        ; for y = 0; y < room->height; y++
        ldx #0
        loop_stack_vertical:
            ldy #1            
            lda PTR_TILE_LEFT+1
            sta (PTR_STACK), Y
            dey
            lda PTR_TILE_LEFT
            sta (PTR_STACK), Y
            clc
            adc #WIDTH_WORLD
            sta PTR_TILE_LEFT
            lda PTR_TILE_LEFT+1
            adc #0
            sta PTR_TILE_LEFT+1
            iny
            iny
            iny
            lda PTR_TILE_RIGHT+1
            sta (PTR_STACK), Y
            dey
            lda PTR_TILE_RIGHT
            sta (PTR_STACK), Y
            clc
            adc #WIDTH_WORLD
            sta PTR_TILE_RIGHT
            lda PTR_TILE_RIGHT+1
            adc #0
            sta PTR_TILE_RIGHT+1
            ; incr ptr_stack
            clc
            lda #4
            adc PTR_STACK
            sta PTR_STACK
            lda #0
            adc PTR_STACK+1
            sta PTR_STACK+1
            ; next y
            inx
            cpx HEIGHT_ROOM
            bne loop_stack_vertical

        ; ## Compute stack's size
       ; UTILISER DIRECTEMENT L ADRESSE DE FIN ET BREAKER QUAND ON L ATTEINT
        sec
        lda PTR_STACK
        sbc #<STACK_ADDR
        pha
        lda PTR_STACK+1
        sbc #>STACK_ADDR
        lsr
        sta SIZE_STACK+1 
        pla 
        ror 
        sta SIZE_STACK

        ; # Opening the first door
        lda #0
        sta NB_DOORS
        lda #<STACK_ADDR
        sta PTR_STACK       ; here stack size < 128, no need for hsb of the address
        loop_first_door:
            jsr Random8
            ldx SIZE_STACK
            jsr Modulus
            asl
            tay            
            lda (PTR_STACK), Y
            ;PTR_TILE =  *PTR_STACK - WIDTH_WORLD
            sec
            sbc #WIDTH_WORLD 
            sta PTR_TILE
            iny
            lda (PTR_STACK), Y
            sbc #0
            sta PTR_TILE+1
            jsr _nb_walkable
            lda NB_WALKABLE
            cmp #2
            bcc loop_first_door ; nb_walkable < 2
        inc NB_DOORS
        ldy #WIDTH_WORLD
        lda #eACTORTYPES::FLOOR_1
        sta (PTR_TILE), Y

        ; # Opening the other doors
        .define IDX ZERO_2_3
        lda #<STACK_ADDR
        sta PTR_STACK       ; here stack size < 128, no need for hsb of the address
        lda #$FF
        sta IDX
        loop_other_doors:
            inc IDX
            ; test if end
            lda SIZE_STACK 
            asl
            cmp IDX
            beq end_loop_other_doors
            ; random number to be compare to the probability of a door
            jsr Random8
            cmp PROBABILITY_OPENING
            bcc test_door
            beq test_door
            inc IDX            
            bcs loop_other_doors ; always jump as the previous bcc failed
            ; test if the tile can be linked to the maze
        test_door:
            ldy IDX
            lda (PTR_STACK), Y
            ;PTR_TILE =  *PTR_STACK - WIDTH_WORLD
            sec
            sbc #WIDTH_WORLD 
            sta PTR_TILE
            iny
            lda (PTR_STACK), Y
            sbc #0
            sta PTR_TILE+1
            sty IDX
            jsr _nb_walkable
            lda NB_WALKABLE
            cmp #2
            bcs carve_a_door            
            bcc loop_other_doors ; always jump as the previous bcs failed
        carve_a_door:
            ldy #WIDTH_WORLD
            lda #eACTORTYPES::FLOOR_1
            sta (PTR_TILE), Y
            inc NB_DOORS
            jmp loop_other_doors
        end_loop_other_doors:

    dec NB_ROOMS
    beq end_loop_connect_rooms

    ; next room
    lda OFFSET_ROOMS
    clc
    adc #.sizeof(Config_Room)
    sta OFFSET_ROOMS
    jmp loop_connect_rooms

    end_loop_connect_rooms:
    rts

; @brief returns the number of walkable neighbours. >= 2 if it can be carved
; @detailed PTR_TILE is offsetted by -WIDTH_WORLD
_nb_walkable:
    lda #0
    sta NB_WALKABLE
    lda #eACTORTYPES::FLOOR_1
    tst_up:
        ldy #0
        cmp (PTR_TILE), Y 
        bne tst_left
        inc NB_WALKABLE
    tst_left:
        ldy #(WIDTH_WORLD-1)
        cmp (PTR_TILE), Y 
        bne tst_right
        inc NB_WALKABLE
    tst_right:
        ldy #(WIDTH_WORLD+1)
        cmp (PTR_TILE), Y 
        bne tst_down
        inc NB_WALKABLE
    tst_down:
        ldy #(2*WIDTH_WORLD)
        cmp (PTR_TILE), Y 
        bne end_is_door_possible
        inc NB_WALKABLE
    end_is_door_possible:
    rts

.undefine STACK_ADDR
.undefine PTR_TILE_TOP   
.undefine PTR_TILE_BOT
.undefine PTR_TILE_LEFT 
.undefine PTR_TILE_RIGHT
.undefine PTR_TILE
.undefine PTR_STACK 
.undefine PROBABILITY_OPENING
.undefine NB_DOORS 
.undefine NB_WALKABLE 
.undefine SIZE_STACK
.undefine WIDTH_ROOM
.undefine HEIGHT_ROOM
.undefine OFFSET_ROOMS

