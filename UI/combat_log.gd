extends VBoxContainer
class_name CombatLog

const COMBAT_LOG_EVENT = preload("uid://c7pcy740cm072")

var events:Array[CombatLogEvent] = []

func _ready() -> void:
	add_log("Hello")
	add_log("This is",10)
	add_log("messsages",12)

func add_log(rich_text_message:String, duration:float = 8):
	var event:CombatLogEvent = COMBAT_LOG_EVENT.instantiate()
	event.text = rich_text_message
	event.duration = duration
	event.timeout.connect(event_timed_out.bind(event))
	add_child(event)

func event_timed_out(event:CombatLogEvent):
	events.erase(event)
	event.queue_free()
