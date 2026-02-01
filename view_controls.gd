extends Control
var cooldown:float = 1

signal finished
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cooldown -=delta
	if cooldown>0:return
	if Input.is_action_just_pressed("action") or\
		Input.is_action_just_pressed("cancel") or\
		Input.is_action_just_pressed("pause"):
		finished.emit()
		queue_free()
