extends LayoutOptions
class_name DrunkardWalkOptions

## Num tiles to walk
@export var num_tiles:int = 250
## Number of tries to walk the requisite number of tiles
@export var max_tiles_walked:int = 1500
## How should this drunk man walk? Orthogonal or all over?
@export var walk_style:WalkStyle = WalkStyle.MANHATTAN
@export var rng_seed:int = randi()
## Width and Height of the grid. Default should be good
@export var size:Vector2i = Vector2i(43,25)
## Top left position of the grid. Default should be good
@export var offset:Vector2i = Vector2i(-15,-14)

enum WalkStyle{
	MANHATTAN, EIGHT_WAY
}

func generate() -> LevelLayout:
	return DrunkardWalkLayout.generate(self)
