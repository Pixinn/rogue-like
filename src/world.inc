; The world contains a Maze, filled with Actors
; Actors can be static, such a a floor or a wall,
; dynamic such as a door
; or alive, such as a monster


.define WIDTH_MAZE 64
.define HEIGHT_MAZE 40
.define SIZE_BORDER 0
.define WIDTH_WORLD  WIDTH_MAZE + 2*SIZE_BORDER
.define HEIGHT_WORLD HEIGHT_MAZE + 2*SIZE_BORDER


.enum ACTORS 

    PLAYER = 0
    
    FLOOR_BLACK = 1
    FLOOR_ORANGE
    FLOOR_VIOLET
    FLOOR_BLUE
    WALKABLE = FLOOR_BLUE ; Player won't be allowed to go on anything > WALKABLE

    NOT_WALKABLE
    NOT_TRANSPARENT = NOT_WALKABLE
    WALL_1  = NOT_WALKABLE
    WALL_2
    
    UNKNOWN

    NB_ACTORS

.endenum
