extends Control
class_name OptionsMenu

@onready var music: Control = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/Music
@onready var sfx: Control = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/SFX
@onready var voice: Control = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/Voice
@onready var deadzone: Control = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer2/Deadzone
@onready var exit: TextButton = $MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/Exit

@onready var selector: Selector = $Selector

signal adjusting_started
signal adjusting_finished
signal menu_exited

var chosen:Option
var state:State

enum State{
	NULL, SELECTING
}

enum Option{
	MUSIC,SFX,VOICE,DEADZONE,EXIT
}

var map:Dictionary[Option, Control]

func _process(delta: float) -> void:
	if state == State.SELECTING:
		adjust(delta)
	

func _ready() -> void:
	selector.options.set(Option.MUSIC, music)
	selector.options.set(Option.SFX, sfx)
	selector.options.set(Option.VOICE, voice)
	selector.options.set(Option.DEADZONE, deadzone)
	selector.options.set(Option.EXIT, exit)
	selector.option_selected.connect(option_selected)
	selector.move_selector.call_deferred()
	map.set(Option.MUSIC, music)
	map.set(Option.SFX, sfx)
	map.set(Option.VOICE, voice)
	map.set(Option.DEADZONE, deadzone)
	map.set(Option.EXIT, exit)
	exit.pressed.connect(exit_press)
	for value in map.values():
		value.highlight(false)
	selector.option_highlighted.connect(highlight_option)
	
func option_selected(val:Option):
	print("Option Selected:", val)
	chosen = val
	if map[chosen] is TextButton:
		map[chosen].press()
		return
	selector.enabled = false
	state = State.SELECTING
	adjusting_started.emit()
	await adjusting_finished
	state = State.NULL
	selector.enabled = true

func adjust(delta):
	if Input.is_action_pressed("right"):
		map[chosen].value += delta/1.5
	if Input.is_action_pressed("left"):
		map[chosen].value -= delta/1.5
	if Input.is_action_just_pressed("action") or Input.is_action_just_pressed("cancel"):
		adjusting_finished.emit()

func highlight_option(integer:Option):
	if map[integer] is OptionSlider:
		var highlighted = map[integer] as OptionSlider
		highlighted.highlight(true)
		selector.option_highlighted.connect(func(_useless:int):highlighted.highlight(false), CONNECT_ONE_SHOT)
		
func exit_press():
	menu_exited.emit()
	queue_free()

func _on_music_value_changed(new_value: float) -> void:
	var bus_index:int = AudioServer.get_bus_index("Music")
	prints("On Music Value Changed",new_value)
	AudioServer.set_bus_volume_linear(bus_index,new_value)
	
	if(new_value == 0):
		AudioServer.set_bus_mute(bus_index,true)
	else:
		AudioServer.set_bus_mute(bus_index,false)
		
	if !Maestro.music_player.playing:
		Maestro.music_player.play()

func _on_sfx_value_changed(new_value: float) -> void:
	var bus_index:int = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_linear(bus_index,new_value)
	
	Maestro.stop_music()
	
	if(new_value == 0):
		AudioServer.set_bus_mute(bus_index,true)
	else:
		AudioServer.set_bus_mute(bus_index,false)
		
	if !Maestro.sfx_player.playing:
		Maestro.sfx_player.play()

func _on_voice_value_changed(new_value: float) -> void:
	var bus_index:int = AudioServer.get_bus_index("Voice")
	AudioServer.set_bus_volume_linear(bus_index,new_value)
	
	Maestro.stop_music()
	
	if(new_value == 0):
		AudioServer.set_bus_mute(bus_index,true)
	else:
		AudioServer.set_bus_mute(bus_index,false)
	
	if !Maestro.voice_player.playing:
		Maestro.voice_player.play()
