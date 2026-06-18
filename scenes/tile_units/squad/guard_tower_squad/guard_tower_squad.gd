extends InfantrySquad
class_name GuardTowerSquad

func _ready():
	rapid_fire_mode = true
	enable_squad_tile_indicator = false
	
func _on_setting_updated(d :SettingData):
	enable_blood = d.extra_effect
	
func _on_member_set_damage_to_tile(_member :SquadMember, tile_id :Vector2, attack_damage :int):
	var dmg = attack_damage * 4 # extra damage agains intruder
	._on_member_set_damage_to_tile(_member, tile_id, dmg)
	
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
	
func update_spotting():
	#.update_spotting()
	
	_attack_tile_ranges = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(), current_tile, attack_range
	) + [current_tile]





