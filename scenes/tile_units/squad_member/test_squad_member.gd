extends SquadMember

onready var tween = $Tween

func melee_attack():
	#.melee_attack()
	iddle = false
	
	tween.interpolate_property(self, "translation", global_position, enemy.global_position, 0.3)
	tween.start()
	yield(tween,"tween_completed")
	
	tween.interpolate_property(self, "translation", global_position, squad.get_formation_position(index), 0.2)
	tween.start()
	yield(tween,"tween_completed")
	
	emit_signal("attack_performed", self, enemy)
	
	iddle = true
	enemy = null
	
func range_attack():
	#.range_attack()
	iddle = false
	
	var arrow = preload("res://scenes/projectiles/arrow.tscn").instance()
	add_child(arrow)
	arrow.translation = global_position
	arrow.to = enemy.global_position
	arrow.launch()
	
	yield(arrow,"on_reach")
	arrow.queue_free()
	
	emit_signal("attack_performed", self, enemy)
	
	# back to ready animation
	iddle = true
	enemy = null
