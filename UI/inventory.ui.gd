extends HBoxContainer

const ITEM_RICH_TEXT = preload("uid://bnn0m1li4otoe")

var inventory:Inventory
@export var max_items:int = 26
@export var items_per_panel:int = 13
@onready var left_panel: VBoxContainer = $"Left Panel"
@onready var right_panel: VBoxContainer = $"Right Panel"
@onready var selector: NinePatchRect = $"../../../Selector"
var item_labels:Dictionary[Item, RichTextLabel]

func _ready() -> void:
	inventory = Inventory.new()
	for i in 20:
		var item = Item.new()
		item.name = Global.random_name()
		inventory.add(item)
	if !inventory: return
	_populate()

func clear():
	for child:Node in left_panel.get_children():
		left_panel.remove_child(child)
	for child:Node in right_panel.get_children():
		right_panel.remove_child(child)
	for item:Item in item_labels.keys():
		item_labels[item].queue_free()
		item_labels.erase(item)

func _populate():
	clear()
	for item:Item in inventory.items:
		var rich_text:RichTextLabel = ITEM_RICH_TEXT.instantiate()
		rich_text.text = "[E]" if item.equipped else ""
		rich_text.text += item.name
		item_labels.set(item, rich_text)
	
	for i in items_per_panel:
		if i < inventory.items.size():
			left_panel.add_child(item_labels[inventory.items[i]])
			
		var j:int = i + items_per_panel
		if j < inventory.items.size():
			right_panel.add_child(item_labels[inventory.items[j]])
