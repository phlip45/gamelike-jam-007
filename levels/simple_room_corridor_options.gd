extends Resource
class_name SimpleRoomCorridorOptions

## How many tries should room gen get? Should be more than 100
@export var tries:int = 1000
## Probably don't need to change this
@export var rng_seed:int = 8675309
## Width and Height of the grid. Default should be good
@export var size:Vector2i = Vector2i(43,25)
## Top left position of the grid. Default should be good
@export var offset:Vector2i = Vector2i(23,23)
## min and max number of rooms. X is min, Y is max. X shouldn't be below 3.
@export var num_rooms:Vector2i = Vector2i(3,10)
## How wide a room can be. X is min, Y is max
@export var room_width:Vector2i = Vector2i(3,10)
## How tall a room can be. X is min, Y is max
@export var room_height:Vector2i = Vector2i(2,7)
## 0.0:1.0 - The higher connectivity means more hallways
## 0.0 will produce only the core hallways. Not Implemented
@export var connectivity:float = 0.0
## Not Implemented
@export var hidden_rooms:bool = false
## Not Implemented
@export var lit_chance:float = 1.0
