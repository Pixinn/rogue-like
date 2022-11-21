.define NB_ACTORS_MAX 128 



.enum ACTORS 

    PLAYER = 0
    ; FLOOR
    FLOOR_1 = 1
    FLOOR_2            ; FLOOR BY DEFAULT
    FLOOR_3
    FLOOR_4
    FLOOR_5
    FLOOR_6
    STAIR_DOWN
    ; OBJECT
    MAP
    ; WALLS
    STAIR_UP
    WALKABLE = STAIR_UP ; Player won't be allowed to go on anything > WALKABLE
    
    NOT_TRANSPARENT = STAIR_UP
    NOT_WALKABLE    
    
    WALL_1  = NOT_WALKABLE
    WALL_2
    
    UNKNOWN

    NB_ACTORS

.endenum