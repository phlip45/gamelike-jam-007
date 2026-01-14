extends CanvasLayer
class_name UI

@export var combat_log:CombatLog

@onready var hp_bar: RichTextLabel = $"UI/Stats/Line 1/HPBarHolder/HPBar"
@onready var stremf_text: RichTextLabel = $"UI/Stats/Line 1/StatBox/StremfText"
@onready var mp_bar: RichTextLabel = $"UI/Stats/Line 2/MPBarHolder/MPBar"
@onready var woowoo_text: RichTextLabel = $"UI/Stats/Line 2/StatBox/WoowooText"
@onready var hunger_text: RichTextLabel = $"UI/Stats/Line 3/Hunger/HungerText"
@onready var whoosh_text: RichTextLabel = $"UI/Stats/Line 3/StatBox/WhooshText"

func _ready() -> void:
	Global.ui = self
	Global.ui_loaded()

var player:Player

func connect_to_player(_player:Player):
	player = _player
	player.stats.stat_changed.connect(stat_changed)
	hp_bar.text = _get_bar_string(player.stats.hp, player.stats.hp_max,BarType.HP)
	mp_bar.text = _get_bar_string(player.stats.mp, player.stats.mp_max,BarType.MP)
	hunger_text.text = "Hunger: "+ player.get_hunger_text()
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
			hunger_text.text = "Hunger: "+ player.get_hunger_text()
		"hunger_max":
			hunger_text.text = "Hunger: "+ player.get_hunger_text()
		"stremf":
			stremf_text.text = "Stremf:" + str(player.stats.stremf)
		"woowoo":
			woowoo_text.text = "Woowoo:" + str(player.stats.woowoo)
		"whoosh":
			whoosh_text.text = "Whoosh:" + str(player.stats.whoosh)
		
