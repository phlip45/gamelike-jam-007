extends RefCounted
class_name Action

var trigger:Trigger
var effect:Callable
var targets:Variant
var get_targets:Callable

enum Type{
	NULL, ATTACK, HEAL
}

var list:Dictionary[Type,Callable] = {
	Type.ATTACK: attack,
	Type.HEAL: heal,
}

var attack:Callable = func(amount:int, target:Actor):
	target.take_damage(amount)

var heal:Callable = func(amount:int, target:Actor):
	target.heal(amount)
