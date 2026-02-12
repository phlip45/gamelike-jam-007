extends CanvasLayer
class_name UI

@export var max_char_on_ground_log:int = 16
@export var max_lines_on_ground_log:int = 16

@export var combat_log:CombatLog
@onready var hp_bar: RichTextLabel = $"UI/Stats/Line 1/HPBarHolder/HPBar"
@onready var stremf_text: RichTextLabel = $"UI/Stats/Line 1/StatBox/StremfText"
@onready var mp_bar: RichTextLabel = $"UI/Stats/Line 2/MPBarHolder/MPBar"
@onready var woowoo_text: RichTextLabel = $"UI/Stats/Line 2/StatBox/WoowooText"
@onready var hunger_text: RichTextLabel = $"UI/Stats/Line 3/Hunger/HungerText"
@onready var whoosh_text: RichTextLabel = $"UI/Stats/Line 3/StatBox/WhooshText"
@onready var inventory_ui: InventoryUI = $"UI/TopPanel/InventoryHolder/MarginContainer/Main View/Inventory"
@onready var ground_log: RichTextLabel = $UI/TopPanel/LeftPanel/MarginContainer/GroundLog
@onready var pause_holder: Control = $PauseHolder

var hp_hyperbole:int
var hp_max_hyperbole:int
var mp_hyperbole:int
var mp_max_hyperbole:int
var stremf_hyperbole:int
var woowoo_hyperbole:int
var whoosh_hyperbole:int

var player:Player

var hunger_words:Dictionary[float,String] = {
	.9: "[color=green]Sated",
	.5: "[color=white]Content",
	.25: "[color=orange]Peckish",
	0.0001: "[color=red]Starving",
	0: "[color=#222]Dying",
}
var hyperbolic_hunger_words:Dictionary[float,String] = {
	.9: "[color=green]Couldn't eat another bite",
	.5: "[color=white]No thanks, just ate",
	.25: "[color=orange]Eh' I could eat",
	0.0001: "[color=red]Warrior needs food badly",
	0: "[color=#222]Not long for this world",
}

signal inventory_closed

func _ready() -> void:
	hp_hyperbole = randi_range(100,999)
	hp_max_hyperbole = randi_range(100,999)
	mp_hyperbole = randi_range(100,999)
	mp_max_hyperbole = randi_range(100,999)
	stremf_hyperbole = randi_range(100,999)
	woowoo_hyperbole = randi_range(100,999)
	whoosh_hyperbole = randi_range(100,999)
	Global.ui = self
	Global.ui_loaded()

func connect_to_player(_player:Player):
	player = _player
	player.stats.stat_changed.connect(stat_changed)
	stat_changed("",1)
	
enum BarType{
	NULL, HP, MP
}

## bars have 45 characters, 43 central bits and the two [] ends
func _get_bar_string(amt:int, _max:int, type:BarType) -> String:
	var percent:float = float(amt)/float(_max)
	var characters_to_illuminate:int = ceil(43*percent) + 1 + 1*percent
	if Global.Settings.hyperbole:
		var full:bool = false
		var zero:bool = false
		if amt == _max:
			full = true
		if amt == 0:
			zero = true
		_max = _max * 1000 + (hp_max_hyperbole if type == BarType.HP else mp_max_hyperbole)
		amt = amt * 1000 + (hp_hyperbole if type == BarType.HP else mp_hyperbole)
		if full:
			amt = _max
		elif zero:
			amt = 0
	var text:String = "~- %s: %s/%s -~" % [("Health" if type == BarType.HP else "Mana"),amt,_max]
	text = text.lpad(22 + floor(text.length()/2.0),"#")
	text = text.rpad(43,"#")
	text = "[" + text + "]"
	text = text.insert(characters_to_illuminate, "[color=#333]")
	if type == BarType.HP and percent < .2:
		text = "[color=%s]" % "red"  + text
	elif type == BarType.HP and percent < .5:
		text = "[color=%s]" % "yellow"  + text
	else:
		text = "[color=%s]" % ("lightgreen" if type == BarType.HP else "lightblue")  + text
	return text
	
func stat_changed(stat_name:String, new_amount:int):
	if Global.Settings.hyperbole:
		hyperbole_stats_changed(stat_name, new_amount)
	hp_bar.text = _get_bar_string(player.stats.hp, player.stats.hp_max,BarType.HP)
	hp_bar.text = _get_bar_string(player.stats.hp, player.stats.hp_max,BarType.HP)
	mp_bar.text = _get_bar_string(player.stats.mp, player.stats.mp_max,BarType.MP)
	mp_bar.text = _get_bar_string(player.stats.mp, player.stats.mp_max,BarType.MP)
	hunger_text.text = "Hunger: "+ get_hunger_text()
	hunger_text.text = "Hunger: "+ get_hunger_text()
	stremf_text.text = "Stremf:" + (str(player.stats.stremf) if !Global.Settings.hyperbole else str(player.stats.stremf * 1000 + stremf_hyperbole))
	woowoo_text.text = "Woowoo:" + (str(player.stats.woowoo) if !Global.Settings.hyperbole else str(player.stats.woowoo * 1000 + woowoo_hyperbole))
	whoosh_text.text = "Whoosh:" + (str(player.stats.whoosh) if !Global.Settings.hyperbole else str(player.stats.whoosh * 1000 + whoosh_hyperbole))
func hyperbole_stats_changed(stat_name:String, _new_amount:int):
	match stat_name:
		"hp":
			hp_hyperbole = randi_range(100,999)
		"hp_max":
			hp_max_hyperbole = randi_range(100,999)
		"mp":
			mp_hyperbole = randi_range(100,999)
		"mp_max":
			mp_max_hyperbole = randi_range(100,999)
		"stremf":
			stremf_hyperbole = randi_range(100,999)
		"woowoo":
			woowoo_hyperbole = randi_range(100,999)
		"whoosh":
			whoosh_hyperbole = randi_range(100,999)

func open_inventory(_inventory:Inventory):
	inventory_ui.open(_inventory)
	await inventory_ui.closed
	inventory_closed.emit()

func set_ground_items(items:Array[Item]) -> void:
	if items.size() == 0:
		ground_log.text = ""
		return
	ground_log.text = "[center]On This Tile:[/center]"
	for i in max_lines_on_ground_log:
		if i >= items.size():
			return
		var item = items[i]
		ground_log.text += "\n"
		ground_log.text += item.name_decoration_start
		ground_log.text += item.name.left(max_char_on_ground_log)
		ground_log.text += item.name_decoration_end

func get_hunger_text() -> String:
	var hungriness:float = float(player.stats.hunger) / float(player.stats.hunger_max)
	
	for key in hunger_words.keys():
		if hungriness >= key and !Global.Settings.hyperbole:
			return hunger_words[key]
		elif hungriness >= key and Global.Settings.hyperbole:
			return hyperbolic_hunger_words[key]
			
	return "[color=#222]Dead"
