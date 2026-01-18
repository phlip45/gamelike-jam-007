@abstract
extends Area2D
class_name Actor

@export var actor_name:String
var cooldown:int = 100
var coord:Vector2i

@warning_ignore("unused_signal")
signal died()

@abstract func take_turn() -> int
