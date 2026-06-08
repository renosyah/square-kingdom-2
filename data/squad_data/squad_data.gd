extends BaseData
class_name SquadData

# general info
export var squad_id :int
export var squad_name :String
export var description :String

# squad scene
export var scene_idx :int
export var node_name :String
export var current_tile :Vector2

# tile unit data
export var network_id :int
export var player_id :String
export var team :int
export var color_idx :int
export var spotting_range :int = 1

# sort order is for ui
# 1 cav : [11] cavalry_household ,[12] cavalry_spear,[13] cavalry_sword,[14] cavalry_archer
# 2 special : [21] elite_guard, [22] huscarls,[23] longbowman
# 3 infantry : [31] pikeman, [32] knight, [33] spearman, [34] swordman, [35] axeman, [36] peasant
# 4 ranges : [41] crossbowman,[42] archer,[43] javeliner
export var sort_order :int

# this is for selection need
# 1 :cavalry
# 2 :infantry melee
# 3 :archer
# 4 :siege engine
export var squad_role :int

# squad data
export var member_scene_idx :int
export var turning_speed :float = 8
export var formation_density :float = 0.35
export var icon_idx :int
export var potrait_idx :int
export var is_mounted :bool = false
export var spawn_time :int = 100

# squad member
export var member_headgear_idx :int
export var member_armor_idx :int
export var member_shield_idx :int
export var member_melee_weapon_idx :int
export var member_range_weapon_idx :int
export var total_member :int = 9


# this is for siege engine
# because i cant get the stats of the engines
# this is just simple holder and not do anything outside data
export var siege_engine_attack_damage :int
export var siege_engine_attack_speed :float
export var siege_engine_attack_range :int

func charge_damage() -> int:
	 # 15 as base charge damage
	var sum = 15 + EntityIndex.melee_weapon_stats[member_melee_weapon_idx]["charge_bonus"]
	sum += sum * EntityIndex.armors_stats[member_armor_idx]["mass"]
	return sum

func attack_range():
	return EntityIndex.range_weapon_stats[member_range_weapon_idx]["range"]

func range_attack_speed():
	return EntityIndex.range_weapon_stats[member_range_weapon_idx]["attack_speed"]
	
func melee_attack_speed():
	return EntityIndex.melee_weapon_stats[member_melee_weapon_idx]["attack_speed"]

func speed() -> float:
	var sum = EntityIndex.head_armors_stats[member_headgear_idx]["speed"]
	sum += EntityIndex.armors_stats[member_armor_idx]["speed"]
	sum += EntityIndex.shield_stats[member_shield_idx]["speed"]
	
	 # 0.5 is base speed of cav
	if is_mounted:
		return 1.85 + sum
		
	 # 0.5 is base speed of infantry
	return 0.75 + sum
	
func member_hp() -> int:
	var sum = EntityIndex.head_armors_stats[member_headgear_idx]["hp"]
	sum += EntityIndex.armors_stats[member_armor_idx]["hp"]
	sum += EntityIndex.shield_stats[member_shield_idx]["hp"]
	
	 # 120 is is base hp cav
	if is_mounted:
		return 120 + sum
		
	# 45 is base hp 
	return 45 + sum 

func heal_amount() -> int:
	return int(member_hp() * 0.15)

func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	scene_idx = _data["a"]
	node_name = _data["a2"]
	current_tile = _data["a3"]
	squad_id = _data["a5"]
	squad_name = _data["a6"]
	description = _data["a7"]
	network_id = _data["b"]
	player_id = _data["c"]
	team = _data["d"]
	color_idx = _data["e"]
	spotting_range = _data["f1"]
	sort_order = _data["f2"]
	squad_role = _data["f3"]
	member_scene_idx = _data["g"]
	turning_speed = _data["j"]
	formation_density = _data["l"]
	icon_idx = _data["l1"]
	potrait_idx = _data["l2"]
	member_headgear_idx = _data["m"]
	member_armor_idx = _data["n"]
	member_shield_idx = _data["o"]
	member_melee_weapon_idx = _data["p"]
	member_range_weapon_idx = _data["q"]
	total_member = _data["t"]
	is_mounted = _data["v"]
	siege_engine_attack_damage = _data["v1"]
	spawn_time = _data["v3"]
	siege_engine_attack_range = _data["v4"]
	siege_engine_attack_speed = _data["v5"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["a"] = scene_idx
	_data["a2"] = node_name
	_data["a3"] = current_tile
	_data["a5"] = squad_id
	_data["a6"] = squad_name
	_data["a7"] = description
	_data["b"] = network_id
	_data["c"] = player_id
	_data["d"] = team
	_data["e"] = color_idx
	_data["f1"] = spotting_range
	_data["f2"] = sort_order
	_data["f3"] = squad_role
	_data["g"] = member_scene_idx
	_data["j"] = turning_speed
	_data["l"] = formation_density
	_data["l1"] = icon_idx
	_data["l2"] = potrait_idx
	_data["m"] = member_headgear_idx
	_data["n"] = member_armor_idx
	_data["o"] = member_shield_idx
	_data["p"] = member_melee_weapon_idx
	_data["q"] = member_range_weapon_idx
	_data["t"] = total_member
	_data["v"] = is_mounted
	_data["v1"] = siege_engine_attack_damage
	_data["v3"] = spawn_time
	_data["v4"] = siege_engine_attack_range
	_data["v5"] = siege_engine_attack_speed
	return _data
	













