extends Resource
class_name Action

@export var name:String
@export var trigger:Trigger
@export var effect_name:Effect.Func
@export var targeter_name:Targeter.TargeterName
@export var effect_modifier:float
var args:Variant

var effects:Dictionary[Effect,Callable]
var get_args_callables:Dictionary[Effect,Callable]

enum Trigger{
	NULL, 
	## Happens [color=red]immediately[/color] upon action use
	IMMEDIATE, 
	## NotImplemented
	START_TURN, 
	## NotImplemented
	END_TURN,
	## NotImplemented
	MOVE,
	## NotImplemented
	DAMAGE,
	## NotImplemented
	HEAL,
	## NotImplemented
	OTHER_STUFF
}

func activate(source:Actor):
	match(trigger):
		Trigger.IMMEDIATE:
			var targeter:Targeter = Targeter.list[targeter_name]
			var targets:Array[Variant] = targeter.get_targets.callv([source])
			var effect:Effect = Effect.func_to_callable[effect_name]
			effect.activate.callv([source, targets, effect_modifier])
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
