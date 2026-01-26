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

var player:Player

var hunger_words:Dictionary[float,String] = {
	.9: "[color=green]Sated",
	.5: "[color=white]Content",
	.25: "[color=orange]Peckish",
	0.0001: "[color=red]Starving",
	0: "[color=#222]Dead",
}

signal inventory_closed

func _ready() -> void:
	Global.ui = self
	Global.ui_loaded()

func connect_to_player(_player:Player):
	player = _player
	player.stats.stat_changed.connect(stat_changed)
	hp_bar.text = _get_bar_string(player.stats.hp, player.stats.hp_max,BarType.HP)
	mp_bar.text = _get_bar_string(player.stats.mp, player.stats.mp_max,BarType.MP)
	hunger_text.text = "Hunger: "+ get_hunger_text()
	stremf_text.text = "Stremf:" + str(player.stats.stremf)
	woowoo_text.text = "Woowoo:" + str(player.stats.woowoo)
	whoosh_text.text = "Whoosh:" + str(player.stats.whoosh)
	
enum BarType{
	NULL, HP, MP
}

## bars have 45 characters, 43 central bits and the two [] ends
func _get_bar_string(amt:int, _max:int, type:BarType) -> String:
	var percent:float = float(amt)/float(_max)
	var characters_to_illuminate:int = ceil(43*percent) + 1 + 1*percent
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
	
func stat_changed(stat_name:String, _new_amount:int):
	match stat_name:
		"hp":
			hp_bar.text = _get_bar_string(player.stats.hp, player.stats.hp_max,BarType.HP)
		"hp_max":
			hp_bar.text = _get_bar_string(player.stats.hp, player.stats.hp_max,BarType.HP)
		"mp":
			mp_bar.text = _get_bar_string(player.stats.mp, player.stats.mp_max,BarType.MP)
		"mp_max":
			mp_bar.text = _get_bar_string(player.stats.mp, player.stats.mp_max,BarType.MP)
		"hunger":
			hunger_text.text = "Hunger: "+ get_hunger_text()
		"hunger_max":
			hunger_text.text = "Hunger: "+ get_hunger_text()
		"stremf":
			stremf_text.text = "Stremf:" + str(player.stats.stremf)
		"woowoo":
			woowoo_text.text = "Woowoo:" + str(player.stats.woowoo)
		"whoosh":
			whoosh_text.text = "Whoosh:" + str(player.stats.whoosh)

func open_inventory(_inventory:Inventory):
	inventory_ui.open(_inventory)
	await inventory_ui.closed
	inventory_closed.emit()

func _on_button_pressed() -> void:
	if inventory_ui.inventory.items.size() == 0: return
	inventory_ui.inventory.remove(inventory_ui.inventory.items.pick_random())

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
		if hungriness >= key:
			return hunger_words[key]
	return "[color=#222]Dead"
