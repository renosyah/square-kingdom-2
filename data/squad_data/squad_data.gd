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

func spawn_time() -> int:
	var sum = 15
	sum += EntityIndex.melee_weapon_stats[member_melee_weapon_idx]["spawn_time"]
	sum += EntityIndex.range_weapon_stats[member_range_weapon_idx]["spawn_time"]
	sum += EntityIndex.head_armors_stats[member_headgear_idx]["spawn_time"]
	sum += EntityIndex.armors_stats[member_armor_idx]["spawn_time"]
	sum += EntityIndex.shield_stats[member_shield_idx]["spawn_time"]
	
	if is_mounted:
		sum += 10
		
	# this must be siege unit
	if not scene_idx in [0, 1]:
		sum += 25
	
	return sum

func squad_attribute() -> Array:
	# base by index
	# 0 type : 0=infantry, 1=cavalry, 2=siege
	var type_squad = 2 if not scene_idx in [0,1] else scene_idx
	
	# 1 melee_weapon : 0:sword/dagger/axe,1:all spear,2:all two handded
	var type_melee_weapon = 0
	if member_melee_weapon_idx in [0,5,6,7,8,11]:
		type_melee_weapon = 0
	elif member_melee_weapon_idx in [2,3,4]:
		type_melee_weapon = 1
	elif member_melee_weapon_idx in [9, 10]:
		type_melee_weapon = 2
		
	# 2 range_weapon :0:null, 1:all trowable, 2:bow/crossbow
	var type_range_weapon = 0
	if member_range_weapon_idx in [1, 2]:
		type_range_weapon = 1
	elif member_range_weapon_idx in [3, 4, 5]:
		type_range_weapon = 2
	
	# 3 armor_type : 0:none, 1:light, 2:medium, 3:heavy
	var type_armor = 0
	if member_armor_idx in [1]:
		type_armor = 1
	elif member_armor_idx in [3]:
		type_armor = 2
	elif member_armor_idx in [2]:
		type_armor = 3
	
	var has_shield = member_shield_idx != 0
	
	return [type_squad, type_melee_weapon, type_range_weapon, type_armor, has_shield]

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
	# 120 is is base hp cav
	var sum = 120 if is_mounted else 45 # 45 is base hp 
	sum += EntityIndex.head_armors_stats[member_headgear_idx]["hp"]
	sum += EntityIndex.armors_stats[member_armor_idx]["hp"]
	sum += EntityIndex.shield_stats[member_shield_idx]["hp"]
	
	# give double HP if commander
	if icon_idx == 6:
		sum += sum
		
	return sum

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
	_data["v4"] = siege_engine_attack_range
	_data["v5"] = siege_engine_attack_speed
	return _data
	













