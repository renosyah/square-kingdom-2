extends BaseSquad

func _init_formations():
	._init_formations()
	
	# flag carrier were center
	_formation_offsets = [
		Vector3.FORWARD + Vector3.LEFT, Vector3.FORWARD, Vector3.FORWARD + Vector3.RIGHT,
		Vector3.ZERO + Vector3.LEFT, Vector3.ZERO, Vector3.ZERO + Vector3.RIGHT,
		Vector3.BACK + Vector3.LEFT, Vector3.BACK,Vector3.BACK + Vector3.RIGHT,
	]
	_formation_positions = _formation_offsets.duplicate()
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	if _has_enemy:
		_is_moving = false
		return
		
	_follow_path_proccess(delta, global_position)
	
func _on_enemy_in_range(delta :float, pos :Vector3, enemy_pos :Vector3):
	._on_enemy_in_range(delta, pos, enemy_pos)
	
	# align Y
	var look :Vector3 = enemy_pos
	look.y = pos.y
	
	# look at enemy position
	var t:Transform = transform.looking_at(look, Vector3.UP)
	transform = transform.interpolate_with(t, turning_speed * delta)
	
	var dir_to :Vector3 = pos.direction_to(look)
	var foward_dir :Vector3 = (-global_transform.basis.z)
	var is_align :bool = foward_dir.dot(dir_to) > 0.85
	
	if not can_attack:
		return
		
	if not is_align or not _attack_timer.is_stopped():
		return
		
	_attack_timer.wait_time = attack_speed
	_attack_timer.start()
	
	# assign the target of enemy squad member
	var iddles :Array = get_iddle_members()
	
	if _is_in_melee_range(enemy):
		
		for i in _members:
			i.prepare_melee_weapon()
		
		if iddles.empty():
			return
		
		var m :SquadMember = iddles.pick_random()
		if not is_instance_valid(m):
			return
			
		# tell to attack 
		# use melee weapon
		var enemy_member :SquadMember = enemy.pick_closes(m.global_position, false)
		if not is_instance_valid(enemy_member):
			return
			
		var target_idx :int = enemy.get_member_index(enemy_member)
		if target_idx == -1:
			return
		
		m.target_idx = target_idx
		m.enemy = enemy_member
		m.melee_attack()
		return
		
	if _has_range_weapon:
		
		for i in _members:
			i.prepare_range_weapon()
			
		for i in iddles:
			if not is_instance_valid(i):
				continue
				
			var enemy_member :SquadMember = enemy.pick_member(false)
			if not is_instance_valid(enemy_member):
				continue
				
			var target_idx :int = enemy.get_member_index(enemy_member)
			if target_idx == -1:
				continue
				
			var m :SquadMember = i
			m.target_idx = target_idx
			m.enemy = enemy_member
			m.range_attack()
			
func take_damage(amount :int, member_idx :int):
	if is_dead:
		return
		
	# shield provide 20% chance of receive no damage
	# even if this hybrid unit using a range weapon
	if _has_shield and randf() < 0.20:
		return

	.take_damage(amount, member_idx)
	
func _move_to_next_path(delta :float, pos :Vector3, to :Vector3):
	#._move_to_next_path(delta, pos, to)
	
	# align Y
	var look :Vector3 = to
	look.y = pos.y
	
	var t:Transform = transform.looking_at(look, Vector3.UP)
	transform = transform.interpolate_with(t, turning_speed * delta)
	
	var dir_to :Vector3 = pos.direction_to(look)
	var foward_dir :Vector3 = (-global_transform.basis.z)
	var is_align :bool = foward_dir.dot(dir_to) > 0.85
	
	if is_align:
		translation += -transform.basis.z * speed * delta
		
func update_spotting():
	.update_spotting()
	
	_melee_ranges = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.ARROW_DIRECTIONS, current_tile, 1
	) + [current_tile]
