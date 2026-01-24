extends Equipment
class_name Weapon

@export var attack_action:Action

func attack(source:Actor):
	attack_action.activate(source)
