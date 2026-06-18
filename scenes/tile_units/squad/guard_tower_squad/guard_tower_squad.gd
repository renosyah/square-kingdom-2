extends InfantrySquad
class_name GuardTowerSquad

func _ready():
	enable_squad_tile_indicator = false
	
func _on_setting_updated(d :SettingData):
	enable_blood = d.extra_effect
	
func _init_formations():
	#._init_formations()
	
	_formation_offsets = [
		Vector3.FORWARD, 
		Vector3.LEFT, Vector3.RIGHT, 
		Vector3.BACK
	]
	
	_formation_positions = _formation_offsets.duplicate()
	
func _on_enemy_in_range(delta :float, pos :Vector3, enemy_pos :Vector3):
	#._on_enemy_in_range(delta, pos, enemy_pos)
	
	if not can_attack:
		return
		
	var dir_to :Vector3 = pos.direction_to(enemy_pos)
	_rotate_to_look(delta, pos, enemy_pos, dir_to)
	
	# range attack only
	_perform_range_attack()

# custom range attack
# making rapid fire mode
func _perform_range_attack():
	if not _has_range_weapon:
		return
		
	if _range_attack_timer.is_stopped():
		_range_attack_timer.wait_time = 0.4
		_range_attack_timer.start()
		
		var iddles :Array = get_iddle_members()
		if iddles.empty():
			return
			
		for i in _members:
			i.prepare_range_weapon()
			
		var enemy_member :SquadMember = enemy.pick_member(false)
		var target_idx :int = enemy.get_member_index(enemy_member)
		if target_idx == -1:
			return
			
		var m :SquadMember = iddles.pick_random()
		m.target_idx = target_idx
		m.enemy = enemy_member
		m.range_attack()

func update_spotting():
	#.update_spotting()
	
	_attack_tile_ranges = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(), current_tile, attack_range
	) + [current_tile]





