extends RichTextLabel
class_name Selector

@export var options:Dictionary[int, Control]
@export var enabled:bool = true
@export var hold_cooldown:Vector2
var selector_index:int
var holding:bool

signal option_selected(integer:int)
signal option_highlighted(integer:int)

func _ready() -> void:
	move_selector.call_deferred.call_deferred()

func _process(delta: float) -> void:
	if !enabled: return
	handle_input(delta)
	
func handle_input(delta:float): 
	process_selector(delta)
	
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
		selector_index = posmod(selector_index-1, options.size())
	elif move > Global.Settings.deadzone:
		selector_index = posmod(selector_index+1, options.size())
	if Input.is_action_just_pressed("action"):
		option_selected.emit(selector_index)
		
	if hold_cooldown.x <= 0:
		hold_cooldown.x = hold_cooldown.y/10 if holding else hold_cooldown.y
		holding = true
	else:  # for example if a mouse is clicked or something.
		hold_cooldown.x = 0
		holding = false
	if move != 0:
		move_selector()
	
func move_selector():
	var control:Control = options.values()[selector_index]
	global_position = control.global_position - Vector2(Global.tile_size.x,0) + Vector2(0,control.size.y /2.0 - size.y/2.0)	
	option_highlighted.emit(selector_index)
