extends RefCounted
class_name Effect

var activate:Callable

enum Func{
	NULL, PHYS_ATTACK, HEAL, RANGED_ATTACK, GOTO_NEXT_LEVEL
}

enum TargeterName{
	NULL, CUR_TARGET_ACTOR
}

static var func_to_callable:Dictionary[Func, Effect]={
	Func.PHYS_ATTACK: phys_attack(),
	Func.RANGED_ATTACK: ranged_attack(),
	Func.GOTO_NEXT_LEVEL: goto_next_level(),
}

static func phys_attack() -> Effect:
	var effect = Effect.new()
	effect.activate = func(source:Actor, targets:Array[Actor]):
		var hits:Dictionary[Actor,int]
		if source.tween:
			source.tween.kill()
		source.tween = source.create_tween()
		source.tween.tween_property(source.symbol,"global_position",targets[0].symbol.global_position, 0.1)
		source.tween.tween_property(source.symbol,"position",source.symbol.offset, 0.1)
		for target:Actor in targets:
			var damage:int = max(source.stats.stremf - target.stats.woowoo,1)
			target.take_damage(damage)
			hits.set(target, damage)
		var message:String = ""
		for hit:Actor in hits:
			message += "%s took [color=red]%s damage!" % [hit.actor_name, hits[hit]]
		Global.push_message(message)
	return effect

static func ranged_attack() -> Effect:
	var effect = Effect.new()
	effect.activate = func(source:Actor, targets:Array[Actor]):
		var hits:Dictionary[Actor,int]
		for target:Actor in targets:
			var projectile = Projectile.create(source.projectile_data)
			source.add_child(projectile)
			projectile.fire_projectile(source.coord, target.coord)
			await projectile.finished
			var damage:int = max(source.stats.whoosh - target.stats.woowoo,1)
			target.take_damage(damage)
			hits.set(target, damage)
		var message:String = ""
		for hit:Actor in hits:
			message += "%s took [color=red]%s damage!" % [hit.actor_name, hits[hit]]
		Global.push_message(message)
	return effect

static func goto_next_level() -> Effect:
	var effect = Effect.new()
	effect.activate = func(source:Actor = null, _targets:Array = []):
		if source is Player:
			source.level.finish_level.call_deferred()
	return effect
