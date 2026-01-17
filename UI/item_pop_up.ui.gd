extends ColorRect
class_name PopUpItemUI

@export var item:Item
var tween:Tween
var starting_size:Vector2
@export var blinder:ColorRect
@export var blinder_color:Color
@export var disabled_color:Color
var state:State
var selectable_options:Array[RichTextLabel]
const ITEM_POP_UP = preload("uid://c623addwcis1o")

@export var hold_cooldown:Vector2 = Vector2(0,.5)
var holding:bool = false

@onready var selector: RichTextLabel = $Selector
var selector_index:int = 0

@onready var title: RichTextLabel = $MarginContainer/Border/MarginContainer/ItemDetails/MarginContainer/VBoxContainer/Title
@onready var description: RichTextLabel = $MarginContainer/Border/MarginContainer/ItemDetails/MarginContainer/VBoxContainer/MarginContainer/Description
@onready var verb: RichTextLabel = $MarginContainer/Border/MarginContainer/ItemDetails/MarginContainer2/VBoxContainer/Verb
@onready var equip: RichTextLabel = $MarginContainer/Border/MarginContainer/ItemDetails/MarginContainer2/VBoxContainer/Equip
@onready var drop: RichTextLabel = $MarginContainer/Border/MarginContainer/ItemDetails/MarginContainer2/VBoxContainer/Drop
@onready var throw: RichTextLabel = $MarginContainer/Border/MarginContainer/ItemDetails/MarginContainer2/VBoxContainer/Throw
@onready var cancel: RichTextLabel = $MarginContainer/Border/MarginContainer/ItemDetails/MarginContainer2/VBoxContainer/Cancel

signal option_chosen(option:Option)

enum Option{
	NULL, VERB, EQUIP, DROP, THROW, CANCEL
}

enum State{
	NULL, AWAITING_INPUT, ANIMATING
}

static func create(_item:Item, _blinder:ColorRect) -> PopUpItemUI:
	var popup:PopUpItemUI = ITEM_POP_UP.instantiate()
	popup.item = _item
	popup.blinder = _blinder
	return popup

func _ready() -> void:
	var dis_color:String = "[color="+disabled_color.to_html(true)+"]"
	title.text = item.name_decoration_start
	title.text += item.name
	title.text += item.name_decoration_end
	description.text = item.description
	if item.consumable:
		verb.text = item.consume_verb 
		selectable_options.append(verb)
	else:
		verb.text = dis_color + "Use"
	if item.equippable:
		equip.text = "Equip" 
		selectable_options.append(equip)
	else:
		equip.text = dis_color + "Equip"
	selectable_options.append_array([drop,throw,cancel])
	drop.text = "Drop"
	throw.text = "Throw"
	cancel.text = "Cancel"
	
	starting_size = size
	state = State.ANIMATING
	_open()

func _process(delta: float) -> void:
	if state == State.AWAITING_INPUT:
		process_selector(delta)
	pass

func process_selector(_delta:float):
	if !Input.is_anything_pressed():
		hold_cooldown.x = 0
		holding = false
		return
	if hold_cooldown.x > 0:
		hold_cooldown.x -= _delta
		return
	var move:float = Input.get_axis("up", "down")
	if move < -Global.Settings.deadzone:
		selector_index = posmod(selector_index-1, selectable_options.size())
	elif move > Global.Settings.deadzone:
		selector_index = posmod(selector_index+1, selectable_options.size())
	if Input.is_action_just_pressed("action"):
		var chosen:Option
		match(selectable_options[selector_index]):
			verb:
				chosen = Option.VERB
			equip:
				chosen = Option.EQUIP
			drop:
				chosen = Option.DROP
			throw:
				chosen = Option.THROW
			cancel:
				chosen = Option.CANCEL
		option_chosen.emit(chosen)
		_close(chosen)
	if Input.is_action_just_pressed("cancel"):
		_close(Option.CANCEL)
		
	if hold_cooldown.x <= 0:
		hold_cooldown.x = hold_cooldown.y/10 if holding else hold_cooldown.y
		holding = true
	else:  # for example if a mouse is clicked or something.
		hold_cooldown.x = 0
		holding = false
	selector.global_position = selectable_options[selector_index].global_position - Vector2(Global.tile_size.x,0)
	pass

func _open():
	tween = create_tween()
	tween.tween_method(func(progress:float):
		size = Vector2(
			floor(starting_size.x*progress / Global.tile_size.x) * Global.tile_size.x,
			floor(starting_size.y*progress/ Global.tile_size.y) * Global.tile_size.y
		)
		blinder.color = blinder.color.lerp(blinder_color,progress)
		if progress == 1:
			size = starting_size
			state = State.AWAITING_INPUT
	,0.0, 1.0, 0.25)
	tween.tween_interval(0.02)
	tween.tween_callback(func():
		selector.global_position = selectable_options[selector_index].global_position - Vector2(Global.tile_size.x,0)
	)
	#tween.tween_interval(1)
	#tween.tween_callback(_close)

func _close(option:Option):
	tween = create_tween()
	tween.tween_method(func(progress:float):
		size = Vector2(
			ceil(starting_size.x*progress / Global.tile_size.x) * Global.tile_size.x,
			ceil(starting_size.y*progress/ Global.tile_size.y) * Global.tile_size.y
		)
		blinder.color = blinder.color.lerp(Color(0,0,0,0),progress)
		if progress == 1:
			state = State.AWAITING_INPUT
	,1.0, 0.0, 0.25)
	tween.tween_callback(option_chosen.emit.bind(option))
	tween.tween_callback(queue_free)
	
	
