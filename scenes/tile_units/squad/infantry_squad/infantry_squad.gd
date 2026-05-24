extends BaseSquad
class_name InfantrySquad

func _init_formations():
	._init_formations()
	
	# flag carrier were center
	_formation_offsets = [
		Vector3.ZERO + Vector3.LEFT, Vector3.ZERO, Vector3.ZERO + Vector3.RIGHT,
		Vector3.FORWARD + Vector3.LEFT, Vector3.FORWARD, Vector3.FORWARD + Vector3.RIGHT,
		Vector3.BACK + Vector3.LEFT, Vector3.BACK,Vector3.BACK + Vector3.RIGHT,
	]
	_formation_positions = _formation_offsets.duplicate()
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	if _has_enemy:
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
			
		# tell to attack 
		# use melee weapon
		var m :SquadMember = iddles.pick_random()
		var enemy_member :SquadMember = enemy.pick_closes(m.global_position, false)
		var target_idx :int = enemy.get_member_index(enemy_member)
		if target_idx == -1:
			return
		
		m.target_idx = target_idx
		m.enemy = enemy_member
		m.melee_attack()
		
		# force stop enemy if on same tile as your squad
		if enemy.current_tile == current_tile and enemy.is_moving():
			enemy.stop()
		
		return
		
	if _has_range_weapon:
		
		for i in _members:
			i.prepare_range_weapon()
			
		for i in iddles:
			var enemy_member :SquadMember = enemy.pick_member(false)
			var target_idx :int = enemy.get_member_index(enemy_member)
			if target_idx == -1:
				continue
				
			var m :SquadMember = i
			m.target_idx = target_idx
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
		
