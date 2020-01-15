; Copyright (C) 2019 Christophe Meneboeuf <christophe@xtof.info>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be usefuELEFT,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program. If not, see <http://www.gnu.org/licenses/>.

.include "../memory.inc"
.include "../world.inc"
.include "../random.inc"
.include "../math.inc"


.export Grow_Maze
.export Remove_Dead_Ends

.import Compute_Maze_Addr
.import World
.import WIDTH_MAZE
.import HEIGHT_MAZE

; using HGR2 space as the stack
; Stack contains pointers to tiles (2 byte long)
.define STACK_ADDR  $3FFE   ; Will be 2 byte incremented before 1st push
.define FALSE #0
.define TRUE #1


.define Y_TILE ZERO_2_4
.define X_TILE ZERO_2_5
.define PTR_STACK ZERO_4_1 ; 2 bytes
.define PTR_NEW_TILE ZERO_4_3 ; 2 bytes


; increments the stack pointer then pushes address A:X (little endian)
; *ptr_stack = x
; *(ptr_stack+1) = a
; ptr_stack += 2
.macro PUSHAX
    pha
    ; increment stack pointer
    clc
    lda PTR_STACK
    adc #2
    sta PTR_STACK
    lda PTR_STACK+1
    adc #0
    sta PTR_STACK+1
    ; push A:X to the stack
    pla
    ldy #1
    sta (PTR_STACK),Y
    dey
    txa
    sta (PTR_STACK),Y
.endmacro

; ptr_newtile is offseted by -WIDTH_WORLD so we can access all its neighbors
; with positive offsets using Y indirect addressing
.macro PTR_UP_TILE
    sec
    ldy #0
    lda (PTR_STACK),Y
    sbc #(2*WIDTH_WORLD)
    sta PTR_NEW_TILE
    iny
    lda (PTR_STACK),Y
    sbc #0
    sta  PTR_NEW_TILE+1
.endmacro
.macro PTR_LEFT_TILE
    sec
    ldy #0
    lda (PTR_STACK),Y
    sbc #(WIDTH_WORLD+1)
    sta PTR_NEW_TILE
    iny
    lda (PTR_STACK),Y
    sbc #0
    sta  PTR_NEW_TILE+1
.endmacro
.macro PTR_RIGHT_TILE
    sec
    ldy #0
    lda (PTR_STACK),Y
    sbc #(WIDTH_WORLD-1)
    sta PTR_NEW_TILE
    iny
    lda (PTR_STACK),Y
    sbc #0
    sta  PTR_NEW_TILE+1
.endmacro
.macro PTR_DOWN_TILE
    ldy #0
    lda (PTR_STACK),Y
    sta PTR_NEW_TILE
    iny
    lda (PTR_STACK),Y
    sta  PTR_NEW_TILE+1
.endmacro
.macro PTR_CURR_TILE
    sec
    ldy #0
    lda (PTR_STACK),Y
    sbc #(WIDTH_WORLD)
    sta PTR_NEW_TILE
    iny
    lda (PTR_STACK),Y
    sbc #0
    sta  PTR_NEW_TILE+1
.endmacro

; test if the tile offseted from PTR_NEW_TILE is walkable
.macro ISWALKABLE offset
    ldy offset
    lda (PTR_NEW_TILE),Y
    cmp #ACTORS::WALKABLE+1
    bcc cannot_carve 
.endmacro



.define OFFSET_NIL #WIDTH_WORLD
.define OFFSET_UP #0
.define OFFSET_RIGHT #(WIDTH_WORLD+1)
.define OFFSET_DOWN #(2*WIDTH_WORLD)
.define OFFSET_LEFT #(WIDTH_WORLD-1)


.macro IS_TILE_WALLED
    PTR_CURR_TILE

    ldy OFFSET_NIL
    lda (PTR_NEW_TILE),Y
    cmp #ACTORS::WALKABLE
    bcc end_loop_stack

    ldy OFFSET_UP
    lda (PTR_NEW_TILE),Y
    cmp #ACTORS::WALKABLE
    bcc end_loop_stack

    ldy OFFSET_RIGHT
    lda (PTR_NEW_TILE),Y
    cmp #ACTORS::WALKABLE
    bcc end_loop_stack

    ldy OFFSET_DOWN
    lda (PTR_NEW_TILE),Y
    cmp #ACTORS::WALKABLE
    bcc end_loop_stack

    ldy OFFSET_LEFT
    lda (PTR_NEW_TILE),Y
    cmp #ACTORS::WALKABLE
    bcc end_loop_stack

.endmacro


; @brief Fills the empty space with a perfect maze
.define PATCH_WIDTH_MAZE_4 0
.define PATCH_HEIGHT_MAZE_4 0
Grow_Maze:

    ; Groth start location
    ldx #2
    stx X_TILE
    stx Y_TILE

loop_grow_maze:

        ; init the stack
        lda #<STACK_ADDR
        sta PTR_STACK
        lda #>STACK_ADDR
        sta PTR_STACK+1

        ; Test if the tile is suitable
        ldy Y_TILE
        ldx X_TILE
        jsr Compute_Maze_Addr   ; result addr in A:X

        ; test if the tile is walled
        PUSHAX 
        IS_TILE_WALLED

        ; carve
        ldy #WIDTH_WORLD
        lda #ACTORS::FLOOR_1
        sta (PTR_NEW_TILE),Y


    .define IDX ZERO_2_6
        ; while the stack is not empty: carve
        loop_stack:

            jsr _random_directions  

            tax
            stx IDX
            loop_find_dir: ; find a direction suitable to carvingm
                jsr _can_carve
                cmp #1     ; cannot carve -> test other directions
                beq carve_the_tile
                lda IDX
                and #3  ; 4th direction?
                cmp #3
                beq test_stack
                inc IDX
                ldx IDX
                jmp loop_find_dir
            test_stack:
                lda PTR_STACK+1
                cmp #>(STACK_ADDR+2)
                bne unstack
                lda PTR_STACK
                cmp #<(STACK_ADDR+2)
                beq end_loop_stack ; stack is empty -> break
            unstack:
                sec
                lda PTR_STACK
                sbc #2
                sta PTR_STACK
                lda PTR_STACK+1
                sbc #0
                sta PTR_STACK+1
                jmp loop_stack
            carve_the_tile:
            ; carve the tile
            ldy #0
            lda #ACTORS::FLOOR_1
            sta (PTR_NEW_TILE),Y
            jmp  loop_stack
        end_loop_stack:

        inc X_TILE
        ldx WIDTH_MAZE 
        dex
        dex
        cpx X_TILE
        beq incr_y_tile
        jmp loop_grow_maze
    incr_y_tile:        
        ldx #2
        stx X_TILE
        inc Y_TILE
        ldy HEIGHT_MAZE
        dey
        cpy Y_TILE
        beq end_loop_grow_maze
        jmp loop_grow_maze

    end_loop_grow_maze:
    rts



.enum
    EUP = 0
    ERIGHT
    EDOWN
    ELEFT
.endenum

; 24 direction quartets
RandomDirection:
.byte EUP,ERIGHT,EDOWN,ELEFT,EUP,ERIGHT,ELEFT,EDOWN,EUP,EDOWN,ERIGHT,ELEFT,EUP,EDOWN,ELEFT,ERIGHT,EUP,ELEFT,ERIGHT,EDOWN,EUP,ELEFT,EDOWN,ERIGHT
.byte ERIGHT,EUP,EDOWN,ELEFT,ERIGHT,EUP,ELEFT,EDOWN,ERIGHT,EDOWN,EUP,ELEFT,ERIGHT,EDOWN,ELEFT,EUP,ERIGHT,ELEFT,EUP,EDOWN,ERIGHT,ELEFT,EDOWN,EUP
.byte EDOWN,ERIGHT,EUP,ELEFT,EDOWN,ERIGHT,ELEFT,EUP,EDOWN,ELEFT,EUP,ERIGHT,EDOWN,ELEFT,ERIGHT,EUP,EDOWN,EUP,ELEFT,ERIGHT,EDOWN,EUP,ERIGHT,ELEFT
.byte ELEFT,ERIGHT,EDOWN,EUP,ELEFT,ERIGHT,EDOWN,EUP,ELEFT,EDOWN,ERIGHT,EUP,ELEFT,EDOWN,EUP,ERIGHT,ELEFT,EUP,ERIGHT,EDOWN,ELEFT,EUP,EDOWN,ERIGHT

; Uses a precomputed table to quickly return an offset to one of the direction quartets
_random_directions:

    jsr Random8
    and #31
    ldx #24
    jsr Modulus
    asl
    asl     ; offset to a direction quartet
    rts

; @brief Returns A=1 if the tile can be carved, A=0 otherwise.
; some difficulties for the branches to be in range to end_can_carve.
; thus the jsr and jmp and the breakdown of the routine
_can_carve:

    lda RandomDirection,X
can_carve_up:
    cmp #EUP
    bne can_carve_right
    jmp _can_carve_up

can_carve_right:
    cmp #ERIGHT
    bne can_carve_down
    jmp _can_carve_right

can_carve_down:
    cmp #EDOWN
    bne can_carve_left
    PTR_DOWN_TILE ; ptr_newtile = down - width_world
    ISWALKABLE OFFSET_NIL       ; the new tile
    ISWALKABLE OFFSET_RIGHT     ; new tile's right neighbor
    ISWALKABLE OFFSET_DOWN      ; new tile's bottom neighbor
    ISWALKABLE OFFSET_LEFT      ; new tile's left neighbor
    jmp _save_ptr_newtile

can_carve_left:
    cmp #ELEFT
    bne end_can_carve
    PTR_LEFT_TILE ; ptr_newtile = left - width_world
    ISWALKABLE OFFSET_NIL       ; the new tile
    ISWALKABLE OFFSET_UP        ; new tile's upper neighbor
    ISWALKABLE OFFSET_DOWN      ; new tile's bottom neighbor
    ISWALKABLE OFFSET_LEFT      ; new tile's left neighbor
    jmp _save_ptr_newtile

cannot_carve:
    lda #0
end_can_carve:
    rts

_can_carve_up:
    PTR_UP_TILE ; ptr_newtile = up - width_world
    ISWALKABLE OFFSET_NIL       ; the new tile
    ISWALKABLE OFFSET_UP        ; new tile's upper neighbor
    ISWALKABLE OFFSET_RIGHT     ; new tile's right neighbor
    ISWALKABLE OFFSET_LEFT      ; new tile's left neighbor
    jmp _save_ptr_newtile

_can_carve_right:
    PTR_RIGHT_TILE ; ptr_newtile = rigth - width_world
    ISWALKABLE OFFSET_NIL       ; the new tile
    ISWALKABLE OFFSET_RIGHT     ; new tile's right neighbor
    ISWALKABLE OFFSET_DOWN      ; new tile's bottom neighbor
    ISWALKABLE OFFSET_UP        ; new tile's upper neighbor
   ; jmp _save_ptr_newtile


; save new tile on the stack
_save_ptr_newtile:
    clc
    lda  PTR_NEW_TILE
    adc #WIDTH_WORLD
    sta PTR_NEW_TILE
    tax
    lda  PTR_NEW_TILE+1
    adc #0
    sta PTR_NEW_TILE+1
    PUSHAX

    ;CREUSER???

    lda #1
    jmp end_can_carve

.undefine Y_TILE
.undefine X_TILE
.undefine PTR_STACK
.undefine PTR_NEW_TILE


.define PTR_TILE        ZERO_2_1    ; 2 bytes
.define PTR_NEXT_TILE   ZERO_2_3    ; 2 bytes
.define NB_WALLS        ZERO_2_5
.define ADDR_END        ZERO_4_1    ; 2 bytes
.define HEIGHTxWIDTH    WIDTH_WORLD*HEIGHT_WORLD
; @brief Removes all the dead ends
Remove_Dead_Ends:

    ; Compute addr_end as the preprocessor cannot handle 16bit multiplications (???)
    lda #WIDTH_WORLD
    sta FAC1
    lda #HEIGHT_WORLD
    sta FAC2
    jsr mul8
    sta ADDR_END+1
    stx ADDR_END
    lda #<World
    clc
    adc ADDR_END
    sta ADDR_END
    lda #>World
    adc ADDR_END+1
    sta ADDR_END+1

    ; starting tile: offsetted by - width_world
    lda #<(World + 1) ; &World[1][1] - width_world
    sta PTR_TILE
    lda #>(World + 1)
    sta PTR_TILE+1

    loop_tiles:
        jsr _is_tile_dead_end
        lda NB_WALLS
        cmp #3
        bcc next_tile

        jsr _follow_dead_end

    next_tile:
        clc 
        lda PTR_TILE
        adc #1
        sta PTR_TILE
        lda PTR_TILE+1
        adc #0
        sta PTR_TILE+1

        ; end?
        lda PTR_TILE+1
        cmp ADDR_END+1
        bne loop_tiles
        lda PTR_TILE
        cmp ADDR_END
        bne loop_tiles
    end_loop_tiles:

    rts
.undefine ADDR_END 

_follow_dead_end:

    ; saving ptr_tile
    lda PTR_TILE
    pha
    lda PTR_TILE+1
    pha

    loop_follow:
        ldy #WIDTH_WORLD
        lda #ACTORS::WALL_1
        sta (PTR_TILE), Y

        lda PTR_NEXT_TILE
        sta PTR_TILE
        lda PTR_NEXT_TILE+1
        sta PTR_TILE+1

        jsr _is_tile_dead_end
        lda NB_WALLS
        cmp #3
        bcs loop_follow

    end_loop_follow:

    ; restoring ptr_tile
    pla
    sta PTR_TILE+1
    pla
    sta PTR_TILE

    rts
    

.define ADD_FACTOR  ZERO_4_1
; REM: PTR_TILE is already offsetted by -WIDTH_WORLD
; for easy access to adjacent tiles by indirect indexing
; Returns : NB_WALLS >= 3 if it is a dead end
_is_tile_dead_end:
    
    lda #0
    sta NB_WALLS
    ldy #WIDTH_WORLD
    sty ADD_FACTOR

    ; Returns if the tile is a wall
    lda #ACTORS::WALKABLE
    cmp (PTR_TILE), Y
    bcc end_tst_up_tile

    tst_up_tile:
        ldy #0
        cmp (PTR_TILE), Y
        bcc up_non_walkable                
        sty ADD_FACTOR
        bcs tst_right_tile
        up_non_walkable:
        inc NB_WALLS
    tst_right_tile:
        ldy #(WIDTH_WORLD + 1)
        cmp (PTR_TILE), Y
        bcc right_non_walkable
        sty ADD_FACTOR
        bcs tst_down_tile
        right_non_walkable:
        inc NB_WALLS        
    tst_down_tile:
        ldy #(2*WIDTH_WORLD)
        cmp (PTR_TILE), Y
        bcc down_non_walkable
        sty ADD_FACTOR
        bcs tst_left_tile
        down_non_walkable:
        inc NB_WALLS
    tst_left_tile:
        ldy #(WIDTH_WORLD - 1)
        cmp (PTR_TILE), Y
        bcc left_non_walkable
        sty ADD_FACTOR
        bcs end_tests
        left_non_walkable:
        inc NB_WALLS

end_tests:
    ; computing ptr_next_tile
    clc
    lda PTR_TILE
    adc ADD_FACTOR
    sta PTR_NEXT_TILE
    lda PTR_TILE+1
    adc #0
    sta PTR_NEXT_TILE+1
    ; offseting ptr_next_tile
    sec
    lda PTR_NEXT_TILE
    sbc #WIDTH_WORLD
    sta PTR_NEXT_TILE
    lda PTR_NEXT_TILE+1
    sbc #0
    sta PTR_NEXT_TILE+1
    
end_tst_up_tile:    
    rts
