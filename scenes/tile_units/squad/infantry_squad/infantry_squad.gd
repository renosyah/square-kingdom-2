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
