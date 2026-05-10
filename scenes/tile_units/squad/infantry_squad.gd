extends BaseSquad

func _follow_path_proccess(delta :float, pos :Vector3):
	
	# stop to attack enemy
	if is_instance_valid(enemy):
		return
		
	._follow_path_proccess(delta, pos)
		
func update_spotting():
	.update_spotting()
	
	_melee_ranges = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(), current_tile, 1
	) + [current_tile]
