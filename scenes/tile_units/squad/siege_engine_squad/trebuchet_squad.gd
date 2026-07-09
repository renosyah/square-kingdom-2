extends SiegeEngineSquad

const fire = preload("res://assets/overtime_damage/area_overtime_damage.tscn")
const fire_particle = preload("res://assets/fire_particle/fire.tscn")

func _init_formations():
	#._init_formations()
	
	# Vector3.ZERO is reserve for siege engine
	_formation_offsets = [
		Vector3.FORWARD + Vector3.LEFT, Vector3.FORWARD + Vector3.RIGHT,
		Vector3.BACK + Vector3.LEFT, Vector3.BACK + Vector3.RIGHT
	]
	_formation_positions = _formation_offsets.duplicate()

func _on_set_damage_to_tile(_engine :SiegeEngine, center_tile_id :Vector2, attack_damage :int):
	if _use_special_ability:
		_set_tile_on_fire(center_tile_id)
		_use_special_ability = false
		return
		
	._on_set_damage_to_tile(_engine, center_tile_id, attack_damage)
	
func _set_tile_on_fire(center_tile_id :Vector2):
	# catapult deal AOE damage
	var tiles :Array = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(), center_tile_id, 1
	) + [center_tile_id]
	
	for tile_id in tiles:
		# spawn fire particle here
		_spawn_fire_particle(nav.get_pos_v3(tile_id))
	
		if _is_master and Global.current_root:
			var b = fire.instance()
			b.tile_id = tile_id
			b.unit_position = unit_position
			b.duration = 15
			b.apply_once = false
			b.connect("on_target_affected", self, "_on_target_affected")
			Global.current_root.add_child(b)

func _spawn_fire_particle(at :Vector3):
	if not Global.current_root:
		return
		
	var f = fire_particle.instance()
	Global.current_root.add_child(f)
	f.translation = at
	f.is_burning = true

func _on_target_affected(squad):
	var damage :int = int(rand_range(12,16))
	var members :Array = squad.get_members(true)
	for idx in members.size():
		squad.take_damage(damage, idx, get_path())











