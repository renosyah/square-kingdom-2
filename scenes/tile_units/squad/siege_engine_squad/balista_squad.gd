extends SiegeEngineSquad

func _on_set_damage_to_tile(_engine :SiegeEngine, tile_id :Vector2, attack_damage :int):
	if not _is_master:
		return
		
	if not unit_position.has(tile_id):
		return
		
	var unit_positions :Array = unit_position[tile_id]
	if unit_positions.empty():
		return
		
	_splash_damage(unit_positions, attack_damage)
