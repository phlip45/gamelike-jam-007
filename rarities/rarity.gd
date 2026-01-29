extends Resource
class_name Rarity

@export var name:String
@export var value:float
@export var color:Color

static func common() -> Rarity:
	var rarity:Rarity = new()
	rarity.name = "Common"
	rarity.value = 100
	return rarity
static func uncommon() -> Rarity:
	var rarity:Rarity = new()
	rarity.name = "Uncommon"
	rarity.value = 30
	return rarity
static func rare() -> Rarity:
	var rarity:Rarity = new()
	rarity.name = "Rare"
	rarity.value = 5
	return rarity
static func legendary() -> Rarity:
	var rarity:Rarity = new()
	rarity.name = "Legendary"
	rarity.value = 2
	return rarity
static func mythic() -> Rarity:
	var rarity:Rarity = new()
	rarity.name = "Mythic"
	rarity.value = 1
	return rarity
