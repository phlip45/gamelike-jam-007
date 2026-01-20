@abstract 
extends RefCounted
class_name AI

func take_turn(enemy:Enemy, _level:Level) -> int:
	## decide what to do
	match enemy.state:
		Enemy.State.NULL:
			pass
		Enemy.State.SLEEPING:
			pass
		Enemy.State.PATROLING:
			pass
		Enemy.State.AGGRO:
			pass
		Enemy.State.DEAD:
			pass
		Enemy.State.SPECIAL0:
			pass
		Enemy.State.SPECIAL1:
			pass
		Enemy.State.SPECIAL2:
			pass
	return 9999
