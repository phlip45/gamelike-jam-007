extends RefCounted
class_name Inventory

var owner:Actor
var items:Array[Item]
var equipped_items:Array[Item]
var weapon_slot:Weapon
var armor_slot:Armor
var ring_slots:Array[Ring]
var max_rings:int = 4
var ring_index:int = 0
@export var max_size:int = 24

signal order_changed()
signal equipment_changed()
signal item_dropped(item:Item)

func get_from_inventory(item:Item) -> Item:
	var found_index = items.find_custom(func(i:Item): return item.name == i.name)
	if found_index == -1: return null	
	return items[found_index]

func get_weapons() -> Array[Item]:
	var weapons:Array[Item] = items.filter(func(a:Item): return a.type == Item.Type.WEAPON)
	return weapons

func unequip(item:Item):
	if item == weapon_slot:
		weapon_slot = null
	item.equipped = false
	equipped_items.erase(item)
	equipment_changed.emit()
	order_changed.emit()
	

func equip(item:Item):
	if item is Weapon:
		if item == weapon_slot:
			item.equipped = false
			equipped_items.erase(item)
			weapon_slot = null
		elif weapon_slot:
			equipped_items.erase(weapon_slot)
			weapon_slot.equipped = false
			item.equipped = true
			equipped_items.append(item)
			weapon_slot = item
		else:
			item.equipped = true
			equipped_items.append(item)
			weapon_slot = item
	if item is Armor:
		if item == armor_slot:
			unequip(item)
			armor_slot = null
		elif armor_slot:
			unequip(armor_slot)
			item.equipped = true
			equipped_items.append(item)
			armor_slot = item
		else:
			item.equipped = true
			equipped_items.append(item)
			armor_slot = item
	if item is Ring:
		if ring_slots.has(item):
			unequip(item)
			ring_slots.erase(item)
		elif ring_slots.size() >= max_rings:
			unequip(ring_slots[ring_index])
			ring_index += 1
			item.equipped = true
			equipped_items.append(item)
			ring_slots.append(item)
		else:
			item.equipped = true
			equipped_items.append(item)
			ring_slots.append(item)
	sort()
	equipment_changed.emit()

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
	if item is Equipment and item.equipped:
		unequip(item)
	remove(item)
	item_dropped.emit(item)

func use(item:Item) -> void:
	if !item.usable: return
	item.use_action.activate(owner)
	subtract(item)

## Erases item completely, does not decrement stackable items
func remove(item:Item) -> bool:
	var index = items.find(item)
	if index == -1: return false
	items.remove_at(index)
	sort()
	order_changed.emit()
	return true

func subtract(item:Item, amount:int = 1) -> bool:
	if item.stackable and item.quantity > amount:
		item.subtract(amount)
	else:
		remove(item)
	return true

func sort() -> void:
	items.sort_custom(sort_alphabetical)
	order_changed.emit()

func sort_alphabetical(a:Item, b:Item) -> bool:
	if a is Equipment and b is Equipment:
		if a.equipped != b.equipped:
			return a.equipped
		else:
			return a.name.naturalnocasecmp_to(b.name) <= 0
	elif (a is Equipment and b is not Equipment) or \
		(a is not Equipment and b is Equipment):
		return a is Equipment
	elif a.name != b.name:
		return a.name.naturalnocasecmp_to(b.name) <= 0
	else:
		return a.id < b.id
