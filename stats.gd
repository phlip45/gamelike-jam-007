extends Resource
class_name Stats

## stat_changed(stat_name:String, new_amount:int) -> emits when stats are changed for any reason
signal stat_changed(stat_name, new_val)

@export var hp:int:
	set(val):
		hp = max(val,0)
		stat_changed.emit("hp", val)
@export var hp_max:int:
	set(val):
		hp_max = max(val,0)
		stat_changed.emit("hp_max", val)
@export var hunger:int:
	set(val):
		hunger = max(val,0)
		stat_changed.emit("hunger", val)
@export var hunger_max:int:
	set(val):
		hunger_max = max(val,0)
		stat_changed.emit("hunger_max", val)
@export var mp:int:
	set(val):
		mp = max(val,0)
		stat_changed.emit("mp", val)
@export var mp_max:int:
	set(val):
		mp_max = max(val,0)
		stat_changed.emit("mp_max", val)
@export var stremf:int:
	set(val):
		stremf = max(val,0)
		stat_changed.emit("stremf", val)
@export var woowoo:int:
	set(val):
		woowoo = max(val,0)
		stat_changed.emit("woowoo", val)
@export var whoosh:int:
	set(val):
		whoosh = max(val,0)
		stat_changed.emit("whoosh", val)
