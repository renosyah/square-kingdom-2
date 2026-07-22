extends RangeWeapon

const shot_sound = preload("res://assets/sounds/weapons/cannon.wav")

onready var animation_player = $AnimationPlayer

func release():
	.release()
	
	animation_player.play("bam")
	
func get_projectile_damage(target, enemy_squad_attribute :Array) -> int:
	var dmg :int = (attack_damage * 2) if target.squad.is_moving() else attack_damage
	if enemy_squad_attribute[3] in [2, 3]: # medium or heavy armor
		return dmg + int(attack_damage * bonus_damage)
	return dmg
	
func get_sound() -> AudioStream:
	return shot_sound
	
# override
func _prepare_pool():
	pass
	
# override
func shot_projectile(target_tile :Vector2, dmg :int, to :Vector3, v :bool):
	yield(get_tree(), "idle_frame")
	emit_signal("on_hit", target_tile, dmg)
