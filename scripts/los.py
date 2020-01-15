#  Copyright (C) 2019 Christophe Meneboeuf <christophe@xtof.info>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#


from bresenham import bresenham
from PIL import Image, ImageDraw
import os


SIZE_GRID = 10
SIZE_TILE  = 64
WIDTH_WORLD = 64
x_player = int(SIZE_GRID/2)
y_player = int(SIZE_GRID/2)

Im = Image.new('RGB',(SIZE_GRID*SIZE_TILE,SIZE_GRID*SIZE_TILE),(255,255,255))
Draw = ImageDraw.Draw(Im)



# fills a rectangle with the given color
def fill_rect(x,y,color):
    Draw.rectangle([SIZE_TILE*x,SIZE_TILE*y,
                    SIZE_TILE*x+SIZE_TILE-1,SIZE_TILE*y+SIZE_TILE-1],
                    outline = (0,0,128),
                    fill = color)

# returns rays from (x0, y0) to (x1, y1)
# output in rays
def compute_rays(x0, y0, x1, y1, rays):
    ray = list(bresenham(x0, y0, x1, y1))
    # Duplicate the ray so that x and y are not incremented at the same time
    duplicated = False
    ray_x = []  # x incremented before y
    ray_y = []  # y incremented before x
    x = ray[0][0]
    y = ray[0][1]
    for tile in ray[1:]:
        if tile[0] != x and tile[1] != y:
            duplicated = True
            ray_x.append((tile[0], y))
            ray_x.append((tile[0], tile[1]))
            ray_y.append((x, tile[1]))
            ray_y.append((tile[0], tile[1]))
        else:
            ray_x.append((tile[0], tile[1]))
            ray_y.append((tile[0], tile[1]))
        x = tile[0]
        y = tile[1]
    
    rays.append(ray_x)
    
    if duplicated:        
        rays.append(ray_y)
    
    return rays



if __name__=="__main__":
    rays = []
    y = 0
    for x in range(0,SIZE_GRID-1):
        rays = compute_rays(x_player,y_player,x,y, rays)
    x = SIZE_GRID-1
    for y in range(0,SIZE_GRID-1):
        rays = compute_rays(x_player,y_player,x,y, rays)
    y = SIZE_GRID-1
    for x in range(SIZE_GRID-1,0,-1):
         rays = compute_rays(x_player,y_player,x,y, rays)
    x = 0
    for y in range(SIZE_GRID-1,0,-1):
        rays = compute_rays(x_player,y_player,x,y, rays)
 

    # create the grid
    for x in range(0,SIZE_GRID):
        for y in range(0,SIZE_GRID):
           fill_rect(x,y,(255,255,255))

    # fill the player
    fill_rect(x_player,y_player,(0,255,0))

    # fill the rays
    nb_cells = 0
    rgb = 0
    for ray in rays:
        for tile in ray:
            fill_rect(tile[0], tile[1], (rgb,rgb,rgb))
            nb_cells += 1
        rgb += int(200 / len(rays))
        
    # print rays
    # [[len(ray), offset_view, offset_world]]
    # offset_world: offset in the world from the 1st tile viewed
    str_ray = "; Nb rays: {}\n".format(len(rays))
    str_ray += "; A ray: length (nb_tiles), offset_from_view_in_world_low,  offset_from_view_in_world_high, offset_view\nRays:\n"
    for ray in rays:
        str_ray += ".byte    " + str(len(ray))
        for tile in ray:
            offset_view = tile[0] + SIZE_GRID*tile[1]
            offset_world = (tile[0] + WIDTH_WORLD*tile[1])
            offset_world_low = offset_world & 0xFF
            offset_world_high = (offset_world >> 8) & 0xFF
            str_ray += ", " + str(offset_world_low) + ", " + str(offset_world_high) + ", " + str(offset_view)
        str_ray += "\n"

    print(str_ray)
    Im.show()

        
