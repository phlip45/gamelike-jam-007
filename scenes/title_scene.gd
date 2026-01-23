extends CanvasLayer

@export var titles:Array[RichTextLabel]
var title_index:int
@export var cooldown:Vector2
@export var options:Array[RichTextLabel]
@onready var selector: RichTextLabel = $Selector

var bloom_spread:float
var bloom_intensity:float
var time_bucket:float

var state:State
@export var hold_cooldown:Vector2
var holding:bool
var selector_index:int

enum State{
	NULL, AWAITING_INPUT, ANIMATING
}

@onready var color_rect_2: ColorRect = $ColorRect2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_index = randi_range(0,titles.size()-1)
	titles[title_index].visible = true

	state = State.AWAITING_INPUT
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_bucket += delta
	cooldown.x -= delta
	if cooldown.x < 0:
		cooldown.x = cooldown.y
		titles[title_index].visible = false
		title_index = posmod(title_index +1 , titles.size())
		titles[title_index].visible = true
	var material = color_rect_2.material as ShaderMaterial
	var amp:float = 1
	var per:float = .5
	var phase:Vector2 = Vector2(0,-.5)
	var intensity:float = amp * sin(per*(time_bucket + phase.x)) + phase.y
	material.set_shader_parameter("bloom_intensity", intensity)
	if sin(time_bucket) > 0.95:
		material.set_shader_parameter("black_offset_multiplier", intensity)
	else:
		material.set_shader_parameter("black_offset_multiplier", .02)
	
	handle_input(delta)
	
func handle_input(delta:float): 
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
		selector_index = posmod(selector_index-1, options.size())
	elif move > Global.Settings.deadzone:
		selector_index = posmod(selector_index+1, options.size())
	if Input.is_action_just_pressed("action"):
		var chosen:RichTextLabel
		match(options[selector_index].text):
			"Start":
				pass
			"Options":
				pass
			"Exit":
				pass
		
	if hold_cooldown.x <= 0:
		hold_cooldown.x = hold_cooldown.y/10 if holding else hold_cooldown.y
		holding = true
	else:  # for example if a mouse is clicked or something.
		hold_cooldown.x = 0
		holding = false
	selector.global_position = options[selector_index].global_position - Vector2(Global.tile_size.x,0)
	pass
