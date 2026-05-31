extends InfantrySquad
class_name GuardTowerSquad

onready var mesh_instance = $MeshInstance
onready var garison_pos = $garison_pos.global_position
onready var invisible_guidance = $invisible_guidance
onready var mesh_instance_2 = $MeshInstance2

func _ready():
	mesh_instance.set_as_toplevel(true)
	mesh_instance.set_surface_material(2, member_material)
	
	mesh_instance_2.set_surface_material(2, member_material)
	mesh_instance_2.visible = false
	reinfoce_tiles = [current_tile]
	
func _on_guard_tower_squad_tree_exiting():
	if Global.current_root:
		remove_child(mesh_instance_2)
		Global.current_root.add_child(mesh_instance_2)
		mesh_instance_2.rotation.y = rotation.y
		mesh_instance_2.translation = global_position
		mesh_instance_2.translation.y = 0.451
		mesh_instance_2.visible = true
		
func _move_to(tile_id :Vector2, use_safe :bool):
	#._move_to(tile_id, use_safe)
	pass # can move
	
func _init_formations():
	#._init_formations()
	
	_formation_offsets = [
		Vector3.FORWARD, 
		Vector3.LEFT, Vector3.RIGHT, 
		Vector3.BACK
	]
	
	_formation_positions = _formation_offsets.duplicate()
	
func _ajust_formation(pos :Vector3, delta :float):
	# _ajust_formation(pos, delta)
	
	var basis :Basis = global_transform.basis
	
	for i in _formation_offsets.size():
		var offset :Vector3 = _formation_offsets[i] * formation_density
		_formation_positions[i] = (pos + garison_pos) + offset
		
	var members = get_members()
	for idx in members.size():
		var m = members[idx]
		m.translation = m.translation.linear_interpolate(_formation_positions[idx], 5 * delta)
		
	mesh_instance.translation.x = pos.x
	mesh_instance.translation.z = pos.z
	
func _follow_path_proccess(delta :float, pos :Vector3) -> void:
	#._follow_path_proccess(delta, pos)
	_path_indicator.translation.y = -10
	
func _on_enemy_in_range(delta :float, pos :Vector3, enemy_pos :Vector3):
	#._on_enemy_in_range(delta, pos, enemy_pos)
	
	if not can_attack:
		return
		
	# align Y
	var is_align :bool = true
	var look :Vector3 = enemy_pos
	look.y = pos.y
	
	var dir_to :Vector3 = pos.direction_to(look)
	
	# look at enemy position
	if _can_look_at(pos, look, dir_to):
		var t:Transform = transform.looking_at(look, Vector3.UP)
		transform = transform.interpolate_with(t, turning_speed * delta)
		
		var foward_dir :Vector3 = (-global_transform.basis.z)
		is_align = foward_dir.dot(dir_to) > align_threshold
		
	if not is_align:
		return
		
	# range attack only
	_perform_range_attack()


func _perform_range_attack():
	if not _has_range_weapon:
		return
		
	if _range_attack_timer.is_stopped():
		_range_attack_timer.start()
		_range_engagement = true
		
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
			if not m.iddle:
				continue
				
			m.target_idx = target_idx
			m.enemy = enemy_member
			m.range_attack()
			return







