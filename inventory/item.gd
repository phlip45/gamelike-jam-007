extends Resource
class_name Item

enum Type{
	NULL,WEAPON,ARMOR,RING,POTION,FOOD,AMMO,SCROLL,BOOK,MISC
}

static var max_quantity:int = 99
var coord:Vector2i
@export var name:String
@export var name_decoration_start:String
@export var name_decoration_end:String
@export_custom(PROPERTY_HINT_MULTILINE_TEXT,"Desc") var description:String
@export var symbol:String
@export var color:Color
@export var type:Type
@export var stackable:bool
@export var quantity:int = 1
@export var equippable:bool
@export var usable:bool
@export var use_verb:String
@export var use_script:GDScript
@export var innate:bool
var equipped:bool = false

func add(amount:int = 1) -> void:
	if !stackable: return
	quantity = min(quantity + amount, max_quantity)

func subtract(amount:int = 1):
	if !stackable and !usable: return
	quantity = max(quantity - amount, 0)
