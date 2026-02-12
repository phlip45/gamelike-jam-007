extends RichTextLabel
class_name TextCheckbox

@export var value:bool:
	set(val):
		value = val
		on_value_changed()
		
signal value_changed

func press():
	value = !value

func on_value_changed():
	value_changed.emit()
	if value:
		text = "[ X ]"
	else:
		text = "[   ]"
