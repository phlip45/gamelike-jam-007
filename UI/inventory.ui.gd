extends HBoxContainer
class_name InventoryUI

const ITEM_RICH_TEXT = preload("uid://bnn0m1li4otoe")

var inventory:Inventory
@export var max_items:int = 26
@export var items_per_panel:int = 13
@onready var left_panel: VBoxContainer = $"Left Panel"
@onready var right_panel: VBoxContainer = $"Right Panel"
@onready var pop_up_holder: MarginContainer = $"../../../PopUpHolder"
@onready var selector: RichTextLabel = $"../../../Selector"
@onready var inventory_holder: ColorRect = $"../../.."
@onready var blinder: ColorRect = $"../../Blinder"
var selector_index:int = 0

@export var hold_cooldown:Vector2 = Vector2(0,.5)
var holding:bool = false

var item_labels:Dictionary[Item, RichTextLabel]

var state:State = State.NULL

enum State{
	NULL,SELECTING,SUBMENU
}

signal opened
signal closed

func _process(delta: float) -> void:
	if state == State.SELECTING:
		select_process(delta)
	pass

func select_process(_delta:float) -> void:
	if !Input.is_anything_pressed():
		hold_cooldown.x = 0
		holding = false
		return
	if hold_cooldown.x > 0:
		hold_cooldown.x -= _delta
		return
	var move = Input.get_vector("left","right","up","down", Global.Settings.deadzone)
	if move.length() > 0:
		move_selector(move)
		#hold_cooldown.x = hold_cooldown.y
		if hold_cooldown.x <= 0:
			hold_cooldown.x = hold_cooldown.y/10 if holding else hold_cooldown.y
			holding = true
	else:  # for example if a mouse is clicked or something.
		hold_cooldown.x = 0
		holding = false
	if Input.is_action_just_pressed("action"):
		if(inventory.items.size() == 0): return
		select(inventory.items[selector_index])
	if Input.is_action_just_pressed("cancel"):
		_close()

func select(item:Item):
	var popup:PopUpItemUI = PopUpItemUI.create(item,blinder)
	pop_up_holder.add_child(popup)
	state = State.SUBMENU
	var option:PopUpItemUI.Option = await popup.option_chosen
	match(option):
		PopUpItemUI.Option.VERB:
			pass
		PopUpItemUI.Option.EQUIP:
			pass
		PopUpItemUI.Option.DROP:
			pass
		PopUpItemUI.Option.THROW:
			pass
		PopUpItemUI.Option.CANCEL:
			state = State.SELECTING

func move_selector(move:Vector2):
	var item_count:int = inventory.items.size()
	if item_count == 0:
		return
	if move.x != 0:
		move_selector_index_horizontal(move.x < 0)
	if move.y != 0:
		move_selector_index_vertical(move.y < 0)
	if selector_index < 0 or selector_index > item_count - 1: return
	#Now we have the proper index so we need to
	#actually move the selector
	var label:RichTextLabel = item_labels[inventory.items[selector_index]]
	selector.global_position = label.global_position - Vector2(Global.tile_size.x,0)

func move_selector_index_vertical(negative:bool):
	var _size = inventory.items.size()
	selector_index += -1 if negative else 1
	selector_index = posmod(selector_index, _size)

func move_selector_index_horizontal(negative:bool):
	var _size = inventory.items.size()
	if _size <= items_per_panel:
		selector_index = 0 if negative else _size - 1
	elif selector_index > items_per_panel - 1:
		selector_index -= items_per_panel
	elif selector_index + items_per_panel >= _size:
		selector_index = _size - 1
	else:
		selector_index += items_per_panel

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
		rich_text.text = item.name_decoration_start
		rich_text.text += "[E]" if item.equipped else ""
		rich_text.text += item.name
		rich_text.text += item.name_decoration_end
		item_labels.set(item, rich_text)
	
	for i in items_per_panel:
		if i < inventory.items.size():
			left_panel.add_child(item_labels[inventory.items[i]])
			
		var j:int = i + items_per_panel
		if j < inventory.items.size():
			right_panel.add_child(item_labels[inventory.items[j]])

func open(_inventory:Inventory):
	if !_inventory:
		printerr("Failed to open inventory")
		_close()
		return
	inventory = _inventory
	_populate()
	inventory.order_changed.connect(_populate)
	inventory_holder.visible = true
	get_tree().create_timer(.3).timeout.connect(func():
		state = State.SELECTING	
	)
	opened.emit()

func _close():
	state = State.NULL
	inventory.order_changed.disconnect(_populate)
	inventory_holder.visible = false
	closed.emit()
