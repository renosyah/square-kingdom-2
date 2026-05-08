extends BaseSquad

func _on_enemy_in_range(delta :float, pos :Vector3, enemy_pos :Vector3):
	#._on_enemy_in_range(delta, pos, enemy_pos)
	
	# align Y
	var look :Vector3 = enemy_pos
	look.y = pos.y
	
	# look at enemy position
	var t:Transform = transform.looking_at(look, Vector3.UP)
	transform = transform.interpolate_with(t, 25 * delta)
	
	if _attack_timer.is_stopped():
		_attack_timer.start()
		
		# randomly pick own squad member
		var m :SquadMember = pick_member()
		if not is_instance_valid(m):
			return
			
		# assign the target of enemy squad member
		m.enemy = enemy.pick_member(false)
		
		if _is_in_melee_range(enemy):
			# tell to attack 
			# use melee weapon
			m.melee_attack()
			return
			
		if has_range_weapon:
			# tell to attack 
			# use range weapon
			m.range_attack()
			
func update_spotting():
	.update_spotting()
	
	_melee_ranges = [current_tile]














