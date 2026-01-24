extends Item
class_name Equipment

@export var equippable:bool
@export var equip_slot:EquipSlot
@export var stats:Stats
var equipped:bool = false

enum EquipSlot{
	NULL, RING, ARMOR, WEAPON
}
