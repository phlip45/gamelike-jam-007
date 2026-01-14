extends RichTextLabel
class_name CombatLogEvent

signal timeout

var duration:float = 8
var tween:Tween

func _process(delta: float) -> void:
	duration -= delta
	if duration < 1 and !tween:
		tween = create_tween()
		tween.tween_property(self,"modulate", Color.TRANSPARENT, .95)
		#tween.parallel()
		#tween.tween_property(self,"scale", Vector2(scale.x,0), .95)
	
	if duration < 0:
		timeout.emit()
