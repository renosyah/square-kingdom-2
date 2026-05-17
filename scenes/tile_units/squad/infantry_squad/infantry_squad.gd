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
	var iddles :Array = get_iddle_member()
	
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
		var enemy_member = enemy.pick_closes(m.global_position, false)
		if not is_instance_valid(enemy_member):
			return
			
		# target_idx = 0 use first one as sacrificial lamb
		m.target_idx = 0
		m.enemy = enemy_member
		m.melee_attack()
		return
		
	if has_range_weapon:
		
		for i in _members:
			i.prepare_range_weapon()
			
		for i in iddles:
			if not is_instance_valid(i):
				continue
				
			var enemy_member = enemy.pick_member(false)
			if not is_instance_valid(enemy_member):
				continue
				
			# tell to attack 
			# use range weapon
			# target_idx = 0 use first one as sacrificial lamb
			var m :SquadMember = i
			m.target_idx = 0
			m.enemy = enemy_member
			m.range_attack()
	
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
