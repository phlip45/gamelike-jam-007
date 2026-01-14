extends Node
class_name Global

static var ui:UI = null
static var grid_offset:Vector2i = Vector2i(-17,-12)
static var grid_size:Vector2i = Vector2i(44,25)
static var tile_size:Vector2i = Vector2i(23,23)
static var signals:BusEvents = BusEvents.new()

static func actor_moved(actor:Actor, coord:Vector2i):
	signals.actor_moved.emit(actor,coord)

static func ui_loaded():
	signals.ui_loaded.emit()

static func push_message(rich_text:String, duration:float = 8):
	if !ui: return
	ui.combat_log.add_log(rich_text,duration)

class BusEvents:
	signal ui_loaded()
	signal actor_moved(player, location)
