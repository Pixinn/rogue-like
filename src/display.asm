
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


.include "display.inc"
.include "world.inc"
.include "tiles.inc"
.include "math.inc"
.include "memory.inc"
.include "monitor.inc"


; Init the view. To be called before anything else!
.export view_init

; Refreshes the view to reflect the world
; destroyed: ZERO_2_1 & ZERO_2_2
.export view_refresh


; Places the upper left corner of the *view* on the given coordinates
; X: in x (values [0:255])
; Y: in y (values [0:255])
; destroyed: ZERO_2_1
.export set_view_coords ; routine to place the view over the world

; Shows a tile at the provided coordinates
; Tile number to be displayed : TILE_NR
; X: TILE_COORD_X
; Y: TILE_COORD_Y

.import compute_maze_addr
.import World
.import Player_XY

.import DBG_TRACE
.import DBG_TRACES

.CODE 


; ********* PRIVATE CONSTANTS ********
; shall be even
.define GRID_WIDTH  $A      
; shall be even
.define GRID_HEIGHT $A

; location of th eplayer in the view
.define PLAYER_X    GRID_WIDTH/2
.define PLAYER_Y    GRID_HEIGHT/2

; sizeof the structure describing a "free tile":
; struct {  int8_t* p_in_world; int8_t  offset_from_player }
.define SIZEOF_TILETRANSP_T 3

; ********* USEFUL VARIABLES & LOCATIONS *******
; x location
.define TILE_COORD_X ZERO_5_3
; y location
.define TILE_COORD_Y ZERO_5_4
; Address of the first tile in the world to be viewed
.define VIEW_WORLD ZERO_4_1        



view_init:

    ; inits the current view to an impossible value
    ; for the first screen refresh
    ldx #(GRID_HEIGHT*GRID_WIDTH - 1)
    lda #$FF 
    sta View_Current
loop_view_init:
        sta View_Current, x
        dex 
        bne loop_view_init

    ; sets the text portion of the mixed mode
    lda #$14
    sta WNDTOP  ; sets the beginning of the text
    jsr HOME    ; clear the text screen and positions the "cursor" 

    jsr HGR     ; HIRES mixed mode, page 1

    rts

; this routine will create the view and populate View_Future
; destroys  ZERO_4_3, ZERO_4_4, ZERO_5_1, ZERO_5_2, ZERO_5_3
;           ZERO_5_4, ZERO_5_5, ZERO_5_6, ZERO_7_1, ZERO_7_2
_build_view:

    ; 1 - Init the view
    lda #0
    ldx #(GRID_WIDTH * GRID_HEIGHT - 1)
    loop_init_view:
        lda #ACTORS::UNKNOWN
        sta View_Future,X
        dex
        bne loop_init_view
    sta View_Future,X

    ; 2 - Player
    .define OFFSET_PLAYER_IN_VIEW PLAYER_X+PLAYER_Y*GRID_WIDTH
    ldx #(OFFSET_PLAYER_IN_VIEW)
    lda #ACTORS::PLAYER
    sta View_Future,X

    ; 3 - Casting rays
    .define NB_RAYS                 36
    .define NB_ITER                 ZERO_4_3
    .define NB_TILES_IN_RAY         ZERO_4_4
    .define NB_TILES_IN_RAY_LEFT    ZERO_5_1
    .define SRC_TILE_IN_WORLD       ZERO_5_2    ; 2 bytes
    .define PTR_RAY                 ZERO_5_4    ; 2 bytes
    .define TMP                     ZERO_5_6

    
    ; loading ptr_rays - 1 as it will be incremented
    ; at the 1st iteration of the loop
    lda #<Rays
    sec
    sbc #1
    sta PTR_RAY
    lda #>Rays
    sbc #0
    sta PTR_RAY+1

    ldx #0
    stx NB_TILES_IN_RAY

    loop_rays:

        stx NB_ITER

        ; computing the pointer to the ray to be casted
        ; ptr_ray += sizeof(ray_elem)*nb elem
        lda NB_TILES_IN_RAY
        sta FAC1
        lda #3      ; sizeof(ray_elem) = 1 byte (offset_view) + 2 bytes (offset_world)
        sta FAC2
        jsr mul8    ; result is alway 8 bit
        inx         ; result += 1
        txa     
        clc
        adc PTR_RAY ; incrementing the ptr to the current ray
        sta PTR_RAY
        lda #0
        adc PTR_RAY+1
        sta PTR_RAY+1


        ; loading nb tiles in ray
        ldy #0
        lda (PTR_RAY),Y
        tax
        stx NB_TILES_IN_RAY
        iny
        
        loop_ray:
            stx NB_TILES_IN_RAY_LEFT

            lda VIEW_WORLD
            clc
            adc (PTR_RAY),Y         ; offset_tile_world_low
            sta SRC_TILE_IN_WORLD
            lda VIEW_WORLD+1
            iny
            adc (PTR_RAY),Y         ; offset_tile_world_high
            sta SRC_TILE_IN_WORLD+1
            iny
            sty TMP
            lda (PTR_RAY),Y         ; offset_view
            tax
            ldy #0
            lda (SRC_TILE_IN_WORLD),Y 
            sta View_Future,X
            ldy TMP
            iny
            ; break if non-transparent
            cmp #ACTORS::NOT_TRANSPARENT
            bcs end_loop_ray
            ; loop if tiles are left in the ray
            
            ldx NB_TILES_IN_RAY_LEFT
            dex
            bne loop_ray

        end_loop_ray:

        ldx NB_ITER
        inx
        cpx #NB_RAYS
        bne loop_rays
    
    end_loop_rays:

    rts

    .undef OFFSET_PLAYER_IN_VIEW
    .undef NB_RAYS                
    .undef NB_ITER                 
    .undef NB_TILES_IN_RAY         
    .undef NB_TILES_IN_RAY_LEFT    
    .undef SRC_TILE_IN_WORLD           
    .undef PTR_RAY                     
    .undef TMP                     




;.align 256
; This routine refreshes (updates) the screen.
; It won't update tiles that are not modified
; destroys  ZERO_2_1, ZERO_2_2,
;           ZERO_4_3, ZERO_4_4, ZERO_5_1, ZERO_5_2, ZERO_5_3,
;           ZERO_5_4, ZERO_5_5, ZERO_5_6, ZERO_7_1, ZERO_7_2
view_refresh:

    ; 1 - computing the start address of the view
    ; to VIEW_WORLD. It places the top-left corner at the given offset    
    lda #<World
    clc
    adc View_Offset
    sta VIEW_WORLD
    lda #>World
    adc View_Offset+1
    sta VIEW_WORLD+1
    ; 2 - shifting the view to place the center at the given offset    
    sec
    lda VIEW_WORLD
    sbc SHIFT_VIEW
    sta VIEW_WORLD
    lda VIEW_WORLD+1
    sbc SHIFT_VIEW+1
    sta VIEW_WORLD+1

    ; 3 - build the view to be displayed
    jsr _build_view

    ; 4 - display the tiles viewed
    .define SAVE_X ZERO_3
    lda #0
    tax
    sta TILE_COORD_Y
loop_display_tiles_y:
        ldy #0
        sty TILE_COORD_X
        loop_display_tiles_x:
            lda View_Future, X
            cmp View_Current, X
            beq no_display      ; do not display an unchanged tile
            sta View_Current, X ; update the list of diplayed tiles
            sta TILE_NR
            stx SAVE_X
            jsr _set_tile        ; this routines does not alter its parameters
            ldx SAVE_X
            no_display:            
            inx     
            inc TILE_COORD_X
            ldy TILE_COORD_X
            tya
            cmp #GRID_WIDTH
            bne loop_display_tiles_x
        ; next line
        inc TILE_COORD_Y
        lda TILE_COORD_Y
        cmp #GRID_HEIGHT
        bne loop_display_tiles_y

    rts
    .undef VIEW_WORLD
SHIFT_VIEW: .word WIDTH_MAZE*PLAYER_Y + PLAYER_X    ; shift to center the view on the player

.CODE
set_view_coords:

    ; 1. Compute offset from the starting address of the maze
    stx ZERO_2_1
    sty FAC1
    lda #WIDTH_MAZE
    sta FAC2
    jsr mul8
    tay ; high part
    txa ; low part
    clc
    adc ZERO_2_1
    sta View_Offset     ; little endian
    tya
    adc #0
    sta View_Offset+1   ; little endian

    rts


;.align 256
; displays tile #TILE_NR at [TILE_COORD_X, TILE_COORD_Y]
; destroys  ZERO_2_1, ZERO_2_2
_set_tile:
    .define ADDR_TO_PATCH  $666 ; 2 byte address to be patched by tile's address
    ; A tile being 16 line tall, it will vertically spawn on two 8 line "blocks"
    .define ADDR_DST_BLOCK_1  ZERO_2_1   ; first block
    .define ADDR_DST_BLOCK_2  ZERO_2_3   ; second bloc

    ; 1 - patching the code with the adress
    ; of the tile to be displayed
    lda TILE_NR
    asl
    tax

    lda TILES, X
    sta PATCH_1+1
    sta PATCH_2+1
    sta PATCH_3+1
    sta PATCH_4+1
    sta PATCH_5+1
    sta PATCH_6+1
    sta PATCH_7+1
    sta PATCH_8+1

    lda TILES+1, X
    sta PATCH_1+2
    sta PATCH_2+2
    sta PATCH_3+2
    sta PATCH_4+2
    sta PATCH_5+2
    sta PATCH_6+2
    sta PATCH_7+2
    sta PATCH_8+2

    ; destination address (HGR)
    ; 2 - get the offset from HGR_GRID (view)
    lda #GRID_WIDTH
    sta FAC1
    lda TILE_COORD_Y
    sta FAC2
    jsr mul8                ; X = GRID_WITH * Y (always < 0xFF)
    txa
    clc
    adc TILE_COORD_X        ; Won't set the carry
    asl                     ; 16 bit elements: doubling the offset. Won't work if grid > 127 tiles (ie 20x10)
    tay                     ; Y: offset to get the address
    ; 3 - retrieve the destination address
    lda HGR_GRID, Y
    sta ADDR_DST_BLOCK_1
    adc #$80
    sta ADDR_DST_BLOCK_2
    lda HGR_GRID+1, Y
    sta ADDR_DST_BLOCK_1+1    
    sta ADDR_DST_BLOCK_2+1
   
    ; 4 - Draw
    ldx #0              ; loop counter & index source
    .define NB_ITER_1 #$20
    ; First loop: draw lines 1 to 8
loop_lines_1to8:
    ldy #0              ; index destination
    ; copy lines (4 blocks)
PATCH_1:    
    lda ADDR_TO_PATCH, X
    sta (ADDR_DST_BLOCK_1), Y
    iny
    inx
PATCH_2:
    lda ADDR_TO_PATCH, X
    sta (ADDR_DST_BLOCK_1), Y
    iny
    inx
PATCH_3:
    lda ADDR_TO_PATCH, X
    sta (ADDR_DST_BLOCK_1), Y
    iny
    inx
PATCH_4:
    lda ADDR_TO_PATCH, X
    sta (ADDR_DST_BLOCK_1), Y
    iny
    inx
    ; next line
    lda ADDR_DST_BLOCK_1+1
    ADC #$4             ; addr += 0x400 
    sta ADDR_DST_BLOCK_1+1
    cpx NB_ITER_1
    bne loop_lines_1to8

    clc                 ; cpx affects carry

    .define NB_ITER_2 #$40
    ; Second loop: draw lines 9 to 16
loop_lines_9to16:
    ldy #0              ; index destination
    ; copy lines (4 blocks)
_DISP_TILE_2:
PATCH_5:
    lda ADDR_TO_PATCH, X
    sta (ADDR_DST_BLOCK_2), Y
    iny
    inx
PATCH_6:
    lda ADDR_TO_PATCH, X
    sta (ADDR_DST_BLOCK_2), Y
    iny
    inx
PATCH_7:
    lda ADDR_TO_PATCH, X
    sta (ADDR_DST_BLOCK_2), Y
    iny
    inx
PATCH_8:
    lda ADDR_TO_PATCH, X
    sta (ADDR_DST_BLOCK_2), Y
    iny
    inx
    ; next line
    lda ADDR_DST_BLOCK_2+1
    ADC #$4             ; addr += 0x400 
    sta ADDR_DST_BLOCK_2+1
    cpx NB_ITER_2
    bne loop_lines_9to16


    rts





.DATA

; Adress of the tiles in the HIRES screen
; T0 T1 T2
; T3 T4 T5
HGR_GRID:
.word $2000, $2004, $2008, $200C, $2010, $2014, $2018, $201C, $2020, $2024
.word $2100, $2104, $2108, $210C, $2110, $2114, $2118, $211C, $2120, $2124
.word $2200, $2204, $2208, $220C, $2210, $2214, $2218, $221C, $2220, $2224
.word $2300, $2304, $2308, $230C, $2310, $2314, $2318, $231C, $2320, $2324
.word $2028, $202C, $2030, $2034, $2038, $203C, $2040, $2044, $2048, $204C
.word $2128, $212C, $2130, $2134, $2138, $213C, $2140, $2144, $2148, $214C
.word $2228, $222C, $2230, $2234, $2238, $223C, $2240, $2244, $2248, $224C
.word $2328, $232C, $2330, $2334, $2338, $233C, $2340, $2344, $2348, $234C
.word $2050, $2054, $2058, $205C, $2060, $2064, $2068, $206C, $2070, $2074
.word $2150, $2154, $2158, $215C, $2160, $2164, $2168, $216C, $2170, $2174

; Nb rays: 36
; A ray: length (nb_tiles), offset_from_view_in_world_low,  offset_from_view_in_world_high, offset_view
Rays:
.byte    5, 4, 1, 44, 195, 0, 33, 130, 0, 22, 65, 0, 11, 0, 0, 0
.byte    5, 4, 1, 44, 195, 0, 33, 131, 0, 23, 66, 0, 12, 1, 0, 1
.byte    5, 4, 1, 44, 196, 0, 34, 131, 0, 23, 67, 0, 13, 2, 0, 2
.byte    5, 5, 1, 45, 196, 0, 34, 132, 0, 24, 67, 0, 13, 3, 0, 3
.byte    5, 5, 1, 45, 197, 0, 35, 132, 0, 24, 68, 0, 14, 4, 0, 4
.byte    5, 5, 1, 45, 197, 0, 35, 133, 0, 25, 69, 0, 15, 5, 0, 5
.byte    5, 5, 1, 45, 197, 0, 35, 134, 0, 26, 70, 0, 16, 6, 0, 6
.byte    5, 5, 1, 45, 198, 0, 36, 134, 0, 26, 71, 0, 17, 7, 0, 7
.byte    5, 6, 1, 46, 198, 0, 36, 135, 0, 27, 71, 0, 17, 8, 0, 8
.byte    5, 6, 1, 46, 199, 0, 37, 135, 0, 27, 72, 0, 18, 9, 0, 9
.byte    4, 6, 1, 46, 199, 0, 37, 136, 0, 28, 73, 0, 19
.byte    4, 6, 1, 46, 199, 0, 37, 200, 0, 38, 137, 0, 29
.byte    4, 6, 1, 46, 7, 1, 47, 200, 0, 38, 201, 0, 39
.byte    4, 70, 1, 56, 7, 1, 47, 8, 1, 48, 9, 1, 49
.byte    4, 70, 1, 56, 71, 1, 57, 72, 1, 58, 73, 1, 59
.byte    4, 70, 1, 56, 135, 1, 67, 136, 1, 68, 137, 1, 69
.byte    4, 134, 1, 66, 135, 1, 67, 200, 1, 78, 201, 1, 79
.byte    4, 134, 1, 66, 199, 1, 77, 200, 1, 78, 9, 2, 89
.byte    4, 134, 1, 66, 199, 1, 77, 8, 2, 88, 73, 2, 99
.byte    4, 134, 1, 66, 199, 1, 77, 7, 2, 87, 72, 2, 98
.byte    4, 134, 1, 66, 198, 1, 76, 7, 2, 87, 71, 2, 97
.byte    4, 133, 1, 65, 198, 1, 76, 6, 2, 86, 70, 2, 96
.byte    4, 133, 1, 65, 197, 1, 75, 5, 2, 85, 69, 2, 95
.byte    4, 133, 1, 65, 196, 1, 74, 4, 2, 84, 68, 2, 94
.byte    4, 132, 1, 64, 196, 1, 74, 3, 2, 83, 67, 2, 93
.byte    4, 132, 1, 64, 195, 1, 73, 3, 2, 83, 66, 2, 92
.byte    4, 132, 1, 64, 195, 1, 73, 2, 2, 82, 65, 2, 91
.byte    5, 132, 1, 64, 195, 1, 73, 194, 1, 72, 1, 2, 81, 64, 2, 90
.byte    5, 132, 1, 64, 131, 1, 63, 194, 1, 72, 193, 1, 71, 0, 2, 80
.byte    5, 68, 1, 54, 131, 1, 63, 130, 1, 62, 193, 1, 71, 192, 1, 70
.byte    5, 68, 1, 54, 67, 1, 53, 130, 1, 62, 129, 1, 61, 128, 1, 60
.byte    5, 68, 1, 54, 67, 1, 53, 66, 1, 52, 65, 1, 51, 64, 1, 50
.byte    5, 68, 1, 54, 67, 1, 53, 2, 1, 42, 1, 1, 41, 0, 1, 40
.byte    5, 68, 1, 54, 3, 1, 43, 2, 1, 42, 193, 0, 31, 192, 0, 30
.byte    5, 4, 1, 44, 3, 1, 43, 194, 0, 32, 193, 0, 31, 128, 0, 20
.byte    5, 4, 1, 44, 195, 0, 33, 194, 0, 32, 129, 0, 21, 64, 0, 10

.BSS

.align 256
View_Current: .res GRID_HEIGHT*GRID_WIDTH   ; current displayed view

View_Offset: .res 2                 ; offset of the corner from HGR_GRID (x,y)

Tiles_Transparent: .res  GRID_WIDTH*SIZEOF_TILETRANSP_T      ; Tiles on the same line as the player that don't block the view
                                                    ; struct {  int8_t* p_in_world; int8_t  offset_from_player}

DBG_NB_REDRAW:  .res 1

; This alignement is **MANDATORY** for the raycasting to work:
; only 8-bit additions are used to compute pointers in this view
.align 256
View_Future: .res GRID_HEIGHT*GRID_WIDTH    ; next displayed view
