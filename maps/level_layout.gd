@abstract
extends Object
class_name LevelLayout

var rect:Rect2i
var rng:RandomNumberGenerator
var tiles:Dictionary[Vector2i,Tile]

@abstract class Options:
	pass

func print():
	prints("Level Layout:",tiles)
