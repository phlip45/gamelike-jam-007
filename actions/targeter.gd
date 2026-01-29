extends Node
class_name Targeter

enum TargeterName{
	NULL, CURRENT_TARGET, SELF, ACTORS_IN_RANGE
}

enum TargetType{
	NULL, ACTOR, TILE, VECTOR2I
}

static var list:Dictionary[TargeterName,Targeter] = {
	TargeterName.CURRENT_TARGET: current_target(),
	TargeterName.SELF: self_target(),
	TargeterName.ACTORS_IN_RANGE: target_in_range(),
}

var get_targets:Callable
var rarity:Rarity

static func current_target() -> Targeter:
	var t:Targeter = new()
	t.get_targets = func(source:Actor) -> Array[Actor]:
		if source.target:
			return [source.target]
		return []
	t.rarity = Rarity.common()
	return t

static func self_target() -> Targeter:
	var t:Targeter = new()
	t.get_targets = func(source:Actor) -> Array[Actor]:
		return [source]
	t.rarity = Rarity.rare()
	return t

static func target_in_range() -> Targeter:
	var t:Targeter = new()
	t.get_targets = func(source:Actor) -> Array[Actor]:
		print_rich("[color=red] TARGET IN RANGE NOT IMPLEMENTED")
		return [source]
	t.rarity = Rarity.rare()
	return t
