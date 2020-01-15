; The world contains a Maze, filled with Actors
; Actors can be static, such a a floor or a wall,
; dynamic such as a door
; or alive, such as a monster


.define MAXIMUM_WIDTH_MAZE 64   ; must be a power of 2
.define MAXIMUM_HEIGHT_MAZE 64  ; must be a power of 2
.define WIDTH_WORLD  64
.define HEIGHT_WORLD 64


.enum ACTORS 

    PLAYER = 0
    
    FLOOR_1 = 1
    FLOOR_2
    FLOOR_3
    FLOOR_4
    WALKABLE = FLOOR_4 ; Player won't be allowed to go on anything > WALKABLE

    NOT_WALKABLE
    NOT_TRANSPARENT = NOT_WALKABLE
    WALL_1  = NOT_WALKABLE
    WALL_2
    
    UNKNOWN

    NB_ACTORS

.endenum
