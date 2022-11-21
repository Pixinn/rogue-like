

.define NB_ACTORS_MAX 128 
.define SIZEOF_ACTORS_T 256+256+128

.enum eACTORTYPES 

    PLAYER = 0      ; PLAYER MUST ALWAYS BE 0
    ; STATIC ACTORS
    ; FLOOR
    FLOOR_1 = 1
    FLOOR_2            ; FLOOR BY DEFAULT
    FLOOR_3
    FLOOR_4
    FLOOR_5
    FLOOR_6
    LAST_FLOOR = FLOOR_6
    ; WALLS
    WALL_1
    WALL_2
    WALL_3
    WALL_4
    LAST_STATIC = WALL_4

    ; DYNAMIC ACTORS
    STAIR_DOWN          ; 11
    FIRST_DYNAMIC = STAIR_DOWN
    STAIR_UP

    ; ITEMS
    MAP                 ; 13

    ; MONSTERS
    RAT                 ; 14
    FIRST_MONSTER = RAT
    TARENTULA
    SERPENT
    LAST_MONSTER = SERPENT  ;16

    NB_ACTORS = 127    
    UNKNOWN = NB_ACTORS

.endenum



