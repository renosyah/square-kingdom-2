extends BaseSquad
class_name InfantrySquad

const walk_sounds = [
	preload("res://assets/sounds/walks/walk_1.wav"),
	preload("res://assets/sounds/walks/walk_2.wav"),
	preload("res://assets/sounds/walks/walk_3.wav")
]

export var align_threshold :float = 0.85

func _init_formations():
	._init_formations()
	
	_formation_offsets = [
		Vector3.ZERO, Vector3.ZERO + Vector3.LEFT,  Vector3.ZERO + Vector3.RIGHT,
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
	
func _on_walking(delta :float):
	if visible and _is_moving and _walk_timer.is_stopped():
		_walk_timer.wait_time = 0.43
		_walk_timer.start()
		_step_audio.stream = walk_sounds.pick_random()
		_step_audio.play()
		
func _on_enemy_in_melee_range(delta :float, pos :Vector3, enemy_pos :Vector3):
	._on_enemy_in_melee_range(delta, pos, enemy_pos)
	
	if not can_attack:
		return
		
	var dir_to :Vector3 = pos.direction_to(enemy_pos)
	_rotate_to_look(delta, pos, enemy_pos, dir_to)
	
	var foward_dir :Vector3 = (-global_transform.basis.z)
	var is_align = foward_dir.dot(dir_to) > align_threshold
	if not is_align:
		return
		
	_perform_melee_attack()
	
func _on_enemy_in_range(delta :float, pos :Vector3, enemy_pos :Vector3):
	._on_enemy_in_range(delta, pos, enemy_pos)
	
	if not can_attack:
		return
		
	var dir_to :Vector3 = pos.direction_to(enemy_pos)
	_rotate_to_look(delta, pos, enemy_pos, dir_to)
	
	var foward_dir :Vector3 = (-global_transform.basis.z)
	var is_align = foward_dir.dot(dir_to) > align_threshold
	if not is_align:
		return
		
	_perform_range_attack()
	
func _perform_melee_attack():
	if _melee_attack_timer.is_stopped():
		_melee_attack_timer.wait_time = get_melee_attack_speed()
		_melee_attack_timer.start()
		
		_melee_engagement = true
		_range_engagement = false
		
		var iddles :Array = get_iddle_members()
		if iddles.empty():
			return
			
		for i in _members:
			i.prepare_melee_weapon()
			
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
		
func _perform_range_attack():
	if not _has_range_weapon:
		return
		
	if _range_attack_timer.is_stopped():
		_range_attack_timer.wait_time = get_range_attack_speed()
		_range_attack_timer.start()
		
		_range_engagement = true
		_melee_engagement = false
		
		var iddles :Array = get_iddle_members()
		if iddles.empty():
			return
			
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
		translation += -transform.basis.z * get_speed() * delta
		translation.y = to.y
