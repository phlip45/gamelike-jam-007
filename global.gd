extends Node
class_name Global

static var ui:UI = null
static var grid_offset:Vector2i = Vector2i(-16,-12)
static var grid_size:Vector2i = Vector2i(43,25)
static var tile_size:Vector2i = Vector2i(23,23)
static var signals:BusEvents = BusEvents.new()

static func actor_moved(actor:Actor, coord:Vector2i):
	signals.actor_moved.emit(actor,coord)

static func ui_loaded():
	signals.ui_loaded.emit()

static func push_message(rich_text:String, duration:float = 8):
	if !ui: return
	ui.combat_log.add_log(rich_text,duration)

static func set_ground_items(items:Array[Item] = []):
	if !ui: return
	ui.set_ground_items(items)
	

static func random_name(length:int = 20) -> String:
	var consonants:Array[String] = ["b","c","d","f","g","h","j","k","l","m","n","p","qu","r","s","t","v","w","x","y","z"]
	var vowels:Array[String] = ["a","e","i","o","u","y"]
	var _name = ""
	var choose_cons:bool = true if randi_range(0,1) == 0 else false
	for i in length:
		var last_space_index = _name.rfind(" ")
		last_space_index = 0 if last_space_index == -1 else last_space_index
		if randi_range(3,6) < i - last_space_index:
			_name += " "
		elif choose_cons:
			_name += consonants.pick_random()
		else:
			_name += vowels.pick_random()
		choose_cons = !choose_cons
	return _name

class BusEvents:
	signal ui_loaded()
	signal actor_moved(player, location)

class Settings:
	static var deadzone:float = 0.2
