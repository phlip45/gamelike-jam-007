extends RefCounted
class_name Inventory

var items:Array[Item]
var equipped_items:Array[Item]
var weapon_slot:Weapon
#var armor_slot:Armor
#var ring_slot_1:Ring
#var ring_slot_2:Ring
#var ring_slot_3:Ring
#var ring_slot_4:Ring
@export var max_size:int = 30

signal order_changed
signal item_dropped(item:Item)

func get_from_inventory(item:Item) -> Item:
	var found_index = items.find_custom(func(i:Item): return item.name == i.name)
	if found_index == -1: return null	
	return items[found_index]

func get_weapons() -> Array[Item]:
	var weapons:Array[Item] = items.filter(func(a:Item): return a.type == Item.Type.WEAPON)
	return weapons

func equip(item:Item):
	if item is Weapon:
		if item == weapon_slot:
			weapon_slot.equipped = false
			weapon_slot = null
			order_changed.emit()
			return
		if weapon_slot:
			weapon_slot.equipped = false
		item.equipped = true
		weapon_slot = item
		order_changed.emit()

func add(item:Item) -> bool:
	var has:Item = get_from_inventory(item)
	if has and has.stackable:
		has.add(item.quantity)
		return true
	elif items.size() > max_size: 
		return false
	items.append(item)
	sort()
	return true

func drop(item:Item) -> void:
	remove(item)
	item_dropped.emit(item)

## Erases item completely, does not decrement stackable items
func remove(item:Item) -> bool:
	var index = items.find(item)
	if index == -1: return false
	items.remove_at(index)
	sort()
	return true

func subtract(item:Item, amount:int = 1) -> bool:
	if item.stackable:
		item.subtract(amount)
	else:
		remove(item)
	return true

func sort() -> void:
	items.sort_custom(sort_alphabetical)
	order_changed.emit()

func sort_alphabetical(a:Item, b:Item) -> bool:
	#if a is Equipment and b is not Equipment:
		#return true
	#else:
		return a.name.naturalnocasecmp_to(b.name) <= 0
