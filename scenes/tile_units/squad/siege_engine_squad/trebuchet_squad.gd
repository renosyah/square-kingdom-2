extends SiegeEngineSquad

func _init_formations():
	#._init_formations()
	
	# Vector3.ZERO is reserve for siege engine
	_formation_offsets = [
		Vector3.FORWARD + Vector3.LEFT, Vector3.FORWARD + Vector3.RIGHT,
		Vector3.BACK + Vector3.LEFT, Vector3.BACK + Vector3.RIGHT
	]
	_formation_positions = _formation_offsets.duplicate()
	
