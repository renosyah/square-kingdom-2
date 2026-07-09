extends SiegeEngineSquad

const bee = preload("res://assets/overtime_damage/area_overtime_damage.tscn")
const bee_particle = preload("res://assets/bee_particle/bee_particle.tscn")

func _on_set_damage_to_tile(_engine :SiegeEngine, center_tile_id :Vector2, attack_damage :int):
	if _use_special_ability:
		_release_the_bee(center_tile_id)
		_use_special_ability = false
		return
		
	._on_set_damage_to_tile(_engine, center_tile_id, attack_damage)
	
func _release_the_bee(center_tile_id :Vector2):
	# catapult deal AOE damage
	var tiles :Array = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(), center_tile_id, 1
	) + [center_tile_id]
	
	# spawn bee particle here
	for tile_id in tiles:
		_spawn_bee_particle(nav.get_pos_v3(tile_id))
		
	if _is_master and Global.current_root:
		var b = bee.instance()
		b.tiles = tiles
		b.unit_position = unit_position
		b.duration = 25
		b.apply_once = true
		b.connect("on_target_affected", self, "_on_target_affected")
		Global.current_root.add_child(b)

func _spawn_bee_particle(at :Vector3):
	if not Global.current_root:
		return
		
	var b = bee_particle.instance()
	Global.current_root.add_child(b)
	b.translation = at

func _on_target_affected(squad):
	squad.set_modifiers([
		[modifier_melee_speed, -0.25, 10, 0],
		[modifier_range_speed,  -0.25, 10, 0],
		[modifier_move_speed,  -0.25, 10, 0],
		[modifier_damage_receive, -0.25, 10, 2],
	])
