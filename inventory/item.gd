extends Resource
class_name Item

enum Type{
	NULL,WEAPON,ARMOR,RING,POTION,FOOD,AMMO,SCROLL,BOOK,MISC
}

static var max_quantity:int = 99
var coord:Vector2i
@export var name:String
@export var symbol:String
@export var type:Type
@export var stackable:bool
@export var quantity:int = 1
@export var equippable:bool
@export var consumable:bool
@export var quaffable:bool
@export var readable:bool
@export var edible:bool
@export var consumable_script:GDScript
var equipped:bool = false

## PONDER: For all this stackable/consumable stuff I'm wondering if it should
## be a subcategory of item.

func add(amount:int = 1) -> void:
	if !stackable: return
	quantity = min(quantity + amount, max_quantity)

func consume(amount:int = 1):
	if !stackable and !consumable: return
	quantity = max(quantity - amount, 0)
