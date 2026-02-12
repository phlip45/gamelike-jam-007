extends RefCounted
class_name Effect

var activate:Callable

enum Func{
	NULL,
	PHYS_ATTACK,
	RANGED_ATTACK,
	CONSUME,
	HEAL,
	GOTO_NEXT_LEVEL
}

enum TargeterName{
	NULL, CUR_TARGET_ACTOR
}

static var func_to_callable:Dictionary[Func, Effect]={
	Func.PHYS_ATTACK: phys_attack(),
	Func.HEAL: heal(),
	Func.RANGED_ATTACK: ranged_attack(),
	Func.GOTO_NEXT_LEVEL: goto_next_level(),
	Func.CONSUME: consume(),
}

static func phys_attack() -> Effect:
	var effect = Effect.new()
	effect.activate = func(source:Actor, targets:Array[Actor], _effect_mod:float = 0):
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
			if Global.Settings.hyperbole:
				var hyperbole_amt:int = randi_range(100,999)
				hits[hit] = hits[hit]*1000 + hyperbole_amt
			message += "%s took [color=red]%s damage!" % [hit.actor_name, hits[hit]]
		Global.push_message(message)
	return effect

static func heal() -> Effect:
	var hyperbole_amt:int = randi_range(100,999)
	var effect = Effect.new()
	effect.activate = func(_source:Actor, targets:Array[Actor], effect_mod:float = 0):
		var hits:Dictionary[Actor,int]
		for target:Actor in targets:
			var heal_amount = effect_mod
			target.heal(heal_amount)
			hits.set(target, heal_amount)
			if target is Player:
				var player = (target as Player)
				player.actor_sound_player.play_sound(player.sounds["drink"])
		if hits.size() > 1:
			print("Fuck")
		var message:String = ""
		for hit:Actor in hits:
			if Global.Settings.hyperbole:
				hits[hit] = hits[hit]*1000 + hyperbole_amt
			message += "%s healed for [color=green]%s!" % [hit.actor_name, hits[hit]]
		Global.push_message(message)
	return effect

static func consume() -> Effect:
	var effect = Effect.new()
	effect.activate = func(_source:Actor, targets:Array[Actor], effect_mod:float = 0):
		var hits:Dictionary[Actor,int]
		for target:Actor in targets:
			var food_amount = effect_mod
			if target is Player:
				target.eat(food_amount)
			else: return
			hits.set(target, food_amount)
		var message:String = ""
		for hit:Actor in hits:
			var player = hit as Player
			if !player: continue
			if hits[hit] > 0:
				message += "Mmmm! That was delicious!"
				player.actor_sound_player.play_sound(player.sounds["mmm"])
			elif hits[hit] == 0:
				message += "Hmmm, didn't taste like much!"
				player.actor_sound_player.play_sound(player.sounds["yuck"])
			else:
				message += "Blegch! Why did I think that would be good to eat!"
				player.actor_sound_player.play_sound(player.sounds["retch"])
		Global.push_message(message)
	return effect

static func ranged_attack() -> Effect:
	var effect = Effect.new()
	effect.activate = func(source:Actor, targets:Array[Actor], _effect_mod:float = 0):
		var hits:Dictionary[Actor,int]
		for target:Actor in targets:
			var projectile = Projectile.create(source.projectile_data)
			source.get_tree().current_scene.add_child(projectile)
			projectile.fire_projectile(source.coord, target.coord)
			await projectile.finished
			if !source: return null
			var damage:int = max(source.stats.whoosh - target.stats.woowoo,1)
			target.take_damage(damage)
			hits.set(target, damage)
		var message:String = ""
		for hit:Actor in hits:
			if Global.Settings.hyperbole:
				var hyperbole_amt:int = randi_range(100,999)
				hits[hit] = hits[hit]*1000 + hyperbole_amt
			message += "%s took [color=red]%s damage!" % [hit.actor_name, hits[hit]]
		Global.push_message(message)
	return effect

static func goto_next_level() -> Effect:
	var effect = Effect.new()
	effect.activate = func(source:Actor = null, _targets:Array = []):
		if source is Player:
			source.level.finish_level.call_deferred()
	return effect
