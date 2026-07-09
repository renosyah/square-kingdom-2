extends SiegeEngineSquad

const overtime_damage_scene = preload("res://assets/overtime_damage/overtime_damage.tscn")

func _on_set_damage_to_tile(_engine :SiegeEngine, tile_id :Vector2, attack_damage :int):
	if not unit_position.has(tile_id):
		return
		
	var unit_positions :Array = unit_position[tile_id]
	if unit_positions.empty():
		return
		
	_normal_damage(unit_positions, attack_damage)
	
	if _use_special_ability:
		_bolt_explode_into_splinter(unit_positions, tile_id)
		_use_special_ability = false
		
func _normal_damage(unit_positions :Array, attack_damage :int):
	if not _is_master:
		return
		
	_splash_damage(unit_positions, attack_damage)
	
func _bolt_explode_into_splinter(unit_positions :Array, tile_id :Vector2):
	if not _is_master:
		return
		
	for enemy_squad in unit_position[tile_id]:
		if not is_instance_valid(enemy_squad):
			continue
			
		var bleed_damage = overtime_damage_scene.instance()
		bleed_damage.damage = int(rand_range(4,7))
		bleed_damage.duration = rand_range(10,15)
		bleed_damage.by = get_path()
		enemy_squad.add_child(bleed_damage)
