extends Resource
class_name Trigger

enum Type{
	NULL, IMMEDIATE, START_TURN, END_TURN, MOVE, DAMAGE, HEAL, OTHER_STUFF
}

@export var type:Type
