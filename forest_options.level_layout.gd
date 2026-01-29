extends LayoutOptions
class_name ForestOptions

## How much of the forest can be trees. 
## Above 50% and it starts getting dicey
@export var density:float = .1
@export var rng_seed:int = randi()
## Width and Height of the grid. Default should be good
@export var size:Vector2i = Vector2i(43,25)
## Top left position of the grid. Default should be good
@export var offset:Vector2i = Vector2i(-15,-14)

func generate() -> LevelLayout:
	return Forest.generate(self)
