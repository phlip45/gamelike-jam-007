extends Resource
class_name Action

@export var name:String
@export var trigger:Trigger
@export var effect_name:Effect.Func
@export var targeter_name:Targeter.TargeterName
var args:Variant

var effects:Dictionary[Effect,Callable]
var get_args_callables:Dictionary[Effect,Callable]

enum Trigger{
	NULL, IMMEDIATE, START_TURN, END_TURN, MOVE, DAMAGE, HEAL, OTHER_STUFF
}

var get_current_target:Callable = func(source:Actor):
	if source.target:
		return source.target
	return null

var heal:Callable = func(amount:int, target:Actor):
	target.heal(amount)

func activate(source:Actor):
	match(trigger):
		Trigger.IMMEDIATE:
			var targeter:Targeter = Targeter.list[targeter_name]
			var targets:Array[Variant] = targeter.get_targets.callv([source])
			var effect:Effect = Effect.func_to_callable[effect_name]
			effect.activate.callv([source, targets])
			pass
		Trigger.START_TURN:
			pass
		Trigger.END_TURN:
			pass
		Trigger.MOVE:
			pass
		Trigger.DAMAGE:
			pass
		Trigger.HEAL:
			pass
		_:
			printerr("Not Implemented")
