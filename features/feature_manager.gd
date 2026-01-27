extends Node
class_name FeatureManager

enum FeatureName{
	NULL, STAIRS
}

@export var feature_resources:Dictionary[FeatureName, Feature]
var level:Level
var features:Array[Feature]

static func create(_level:Level):
	var FEATURE_MANAGER = load("uid://qrlunhekn3he")
	var manager:FeatureManager = FEATURE_MANAGER.instantiate()
	manager.level = _level
	return manager

func add_feature(feature:Feature):
	feature.coord = level.layout.get_random_floor().coord
	feature.teleport(feature.coord,false)
	feature.destroyed.connect(remove_feature.bind(feature),CONNECT_ONE_SHOT)
	features.append(feature)
	add_child(feature)

func remove_feature(feature:Feature):
	features.erase(feature)
	remove_child(feature)

func check_visibility():
	for feature:Feature in features:
		feature.check_visibility()
