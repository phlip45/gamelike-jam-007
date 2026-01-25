extends CanvasLayer

@onready var color_rect_2: ColorRect = $ClickDetector/ColorRect2
@onready var anti_click_shader: TextureRect = $AntiClickShader
@onready var click_detector: Button = $ClickDetector

@export var titles:Array[RichTextLabel]
var title_index:int
@export var cooldown:Vector2
@export var options:Array[RichTextLabel]
@onready var selector: Selector = $Selector
@onready var option_menu_hodler: Control = $OptionMenuHodler

var bloom_spread:float
var bloom_intensity:float
var time_bucket:float

# selector
var state:State
@export var hold_cooldown:Vector2
var holding:bool
var selector_index:int

enum State{
	NULL, AWAITING_INPUT, ANIMATING
}


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

func start():
	get_tree().change_scene_to_file("res://scenes/level.tscn")
func open_options():
	selector.enabled = false
	var option_menu_scene:PackedScene = load("res://scenes/options.tscn")
	var option_menu:OptionsMenu = option_menu_scene.instantiate()
	option_menu_hodler.add_child(option_menu)
	await option_menu.menu_exited
	selector.enabled = true
func exit():
	get_tree().quit()

func _on_click_detector_pressed() -> void:
	anti_click_shader.visible = true
	get_tree().create_timer(1).timeout.connect(func():
		anti_click_shader.visible = false
		click_detector.release_focus()
	)

func _on_selector_option_highlighted(integer: int) -> void:
	if selector.options[integer].has_method("highlight"):
		var highlighted = selector.options[integer]
		highlighted.highlight(true)
		selector.option_highlighted.connect(func(_useless:int):highlighted.highlight(false), CONNECT_ONE_SHOT)

func _on_selector_option_selected(integer: int) -> void:
	if selector.options[integer].has_method("press"):
		selector.options[integer].press()
