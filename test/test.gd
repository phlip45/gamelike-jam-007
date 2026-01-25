extends Node

const PLAYER = preload("uid://lcvhdr41todm")
#var player:Player

var weapon:Weapon

func _init()-> void:
	var item:Weapon = Weapon.new()
	item.name = "working"
	weapon = item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player = PLAYER.instantiate()
	#add_child(player)
	var thing:RichTextLabel = RichTextLabel.new()
	var other_thing:RichTextLabel = RichTextLabel.new()
	thing.add_child(other_thing)
	add_child(thing)
	pass # Replace with function body.

var sum:Callable = func(a:int, b:int):
	print(a , b)


func _on_button_pressed() -> void:
	print("Hello")
