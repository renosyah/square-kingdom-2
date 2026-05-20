extends Equipment
class_name RangeWeapon

signal on_hit(projectile_pos)

export var projectile :PackedScene
export var attack_damage :int
export var show_on_stored :bool = true

export var walk_animation :String = "walk"
export var ready_animation :String = "iddle"
export var attack_animation :String = "shot_range_weapon"

func pull():
	pass
	
func release():
	pass
	
func shot_projectile(to :Vector3):
	var arrow :BaseProjectile = projectile.instance()
	add_child(arrow)
	arrow.translation = global_position
	arrow.to = to + Vector3.ONE * rand_range(-0.5,0.5)
	arrow.launch()
	
	yield(arrow,"on_reach")
	
	emit_signal("on_hit", arrow.global_position)
	
	yield(get_tree().create_timer(1),"timeout")
	arrow.queue_free()
