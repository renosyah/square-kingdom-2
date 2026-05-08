extends BaseSquad

func _follow_path_proccess(delta :float, pos :Vector3):
	
	# stop to attack enemy
	# dont move
	if is_instance_valid(enemy):
		return
		
	._follow_path_proccess(delta, pos)
