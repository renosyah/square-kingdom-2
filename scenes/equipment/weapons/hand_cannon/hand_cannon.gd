extends RangeWeapon

const shot_sound = preload("res://assets/sounds/weapons/cannon.wav")

onready var animation_player = $AnimationPlayer

func release():
	.release()
	
	animation_player.play("bam")
	
func get_projectile_damage(_target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[3] in [2, 3]: # medium or heavy armor
		return attack_damage + int(attack_damage * bonus_damage)
	return attack_damage
	
func get_sound() -> AudioStream:
	return shot_sound
	
# override
func _prepare_pool():
	pass
	
func _on_projectile_reach(arrow):
	pass
	
# override
func shot_projectile(to :Vector3, v :bool):
	yield(get_tree(), "idle_frame")
	emit_signal("on_hit", to)
