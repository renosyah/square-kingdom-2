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

# special stats
export var is_mounted :bool = false
export var is_hero :bool = false
export var is_commander :bool = false

# squad member
export var member_headgear_idx :int
export var member_armor_idx :int
export var member_shield_idx :int
export var member_melee_weapon_idx :int
export var member_range_weapon_idx :int
export var total_member :int = 9

# choosen ability
export var squad_ability_idx :int = 0
export var range_fire_mode :int = 0 # 0:volley 1:rappid

# this is for siege engine
# because i cant get the stats of the engines
# this is just simple holder and not do anything outside data
export var siege_engine_attack_damage :int
export var siege_engine_attack_speed :float
export var siege_engine_attack_range :int

# this is just carrier of something like bonus
export var extra :Dictionary # ArmyCardData {}
export var biom :int # for modifier base by biom

func spawn_time() -> float:
	if is_commander:
		return 5.0 # commander always 5 second
		
	var _spawn_time = 15.0
	_spawn_time += EntityIndex.melee_weapon_stats[member_melee_weapon_idx]["spawn_time"]
	_spawn_time += EntityIndex.range_weapon_stats[member_range_weapon_idx]["spawn_time"]
	_spawn_time += EntityIndex.head_armors_stats[member_headgear_idx]["spawn_time"]
	_spawn_time += EntityIndex.armors_stats[member_armor_idx]["spawn_time"]
	_spawn_time += EntityIndex.shield_stats[member_shield_idx]["spawn_time"]
	
	if is_mounted:
		_spawn_time += 10.0
		
	# this must be siege unit
	if not scene_idx in [0, 1]:
		_spawn_time += 25.0
		
	# bonus by extra
	if extra.has("spawn_time_decrease_percentage"):
		var _v = clamp(1.0 + extra["spawn_time_decrease_percentage"], 0.01, 1.99)
		_spawn_time = _spawn_time / _v  # dont allow divide by 0
		
	if extra.has("spawn_time_decrease_value"):
		_spawn_time = _spawn_time - extra["spawn_time_decrease_value"]
	
	return max(_spawn_time, 1.0) # prevent below 1 second

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
	var _range_attack_speed = EntityIndex.range_weapon_stats[member_range_weapon_idx]["attack_speed"]
	if extra.has("range_speed_bonus_percentage"):
		var _v = clamp(1.0 + extra["range_speed_bonus_percentage"], 0.01, 1.99)
		_range_attack_speed = _range_attack_speed / _v
	if extra.has("range_speed_bonus_value"):
		_range_attack_speed = _range_attack_speed - extra["range_speed_bonus_value"]
		
	if biom == 2:
		_range_attack_speed = _range_attack_speed + (_range_attack_speed * 0.20)
		
	return max(_range_attack_speed, 0.12) # prevent below 0.12
	
func melee_attack_speed():
	var _squad_attribute = squad_attribute()
	var _melee_attack_speed = EntityIndex.melee_weapon_stats[member_melee_weapon_idx]["attack_speed"]
	if extra.has("melee_speed_bonus_percentage"):
		var _v = clamp((1.0 + extra["melee_speed_bonus_percentage"]), 0.01, 1.99)
		_melee_attack_speed = _melee_attack_speed / _v
	if extra.has("melee_speed_bonus_value"):
		_melee_attack_speed = _melee_attack_speed - extra["melee_speed_bonus_value"]
		
	# in biom desert
	# using heavy armor, attack speed slower -15%
	if biom == 1 and _squad_attribute[3] == 3:
		_melee_attack_speed = _melee_attack_speed + (_melee_attack_speed * 0.15)
		
	return max(_melee_attack_speed, 0.11) # prevent below 0.11

func speed() -> float:
	var _squad_attribute = squad_attribute()
	var _speed = EntityIndex.head_armors_stats[member_headgear_idx]["speed"]
	_speed += EntityIndex.armors_stats[member_armor_idx]["speed"]
	_speed += EntityIndex.shield_stats[member_shield_idx]["speed"]
	
	if extra.has("speed_bonus_percentage"):
		_speed = _speed * (1.0 + extra["speed_bonus_percentage"])
	if extra.has("speed_bonus_value"):
		_speed = _speed + extra["speed_bonus_value"]
		
	_speed = max(_speed, 0.1)
	
	# siege engine
	if not scene_idx in [0, 1]:
		return 0.34 + _speed
		
	 # 0.5 is base speed of cav
	if is_mounted:
		return 1.85 + _speed
		
	# in biom desert
	# using heavy armor, speed reduce by -10%
	if biom == 1 and _squad_attribute[3] == 3:
		_speed = _speed - (_speed * 0.10)
		
	# in biom winter
	# using no armor, speed reduce by -10%
	elif biom == 2 and _squad_attribute[3] == 0:
		_speed = _speed - (_speed * 0.10)
		
	_speed = max(_speed, 0.01)
		
	 # 0.5 is base speed of infantry
	return 0.75 + _speed
	
func member_hp() -> int:
	# 120 is is base hp cav
	var _member_hp = 120 if is_mounted else 45 # 45 is base hp 
	_member_hp += EntityIndex.head_armors_stats[member_headgear_idx]["hp"]
	_member_hp += EntityIndex.armors_stats[member_armor_idx]["hp"]
	_member_hp += EntityIndex.shield_stats[member_shield_idx]["hp"]
	
	# give double HP if commander
	if is_commander:
		_member_hp += _member_hp
		
	 # special hp for singular unit
	if is_hero:
		_member_hp += 1000
		
	if extra.has("hp_bonus_percentage"):
		_member_hp = int(_member_hp * (1.0 + extra["hp_bonus_percentage"]))
	if extra.has("hp_bonus_value"):
		_member_hp = _member_hp + extra["hp_bonus_value"]
		
	return int(max(_member_hp, 1)) # prevent below 1 LOL

func heal_amount() -> int:
	var _member_hp = member_hp()
	var _heal_amount = int(_member_hp * (0.25 if is_hero else 0.15))
	
	if extra.has("heal_bonus_percentage"):
		var _v = clamp((1.0 + extra["heal_bonus_percentage"]), 0.99, 1.99)
		_heal_amount = _heal_amount * _v
	if extra.has("heal_bonus_value"):
		_heal_amount = _heal_amount + extra["heal_bonus_value"]
		
	# in the desert, 25% less heal
	if biom == 1:
		_heal_amount = int(_heal_amount - (_heal_amount * 0.25))
	elif biom == 2:
		_heal_amount = int(_heal_amount - (_heal_amount * 0.10))
	
	return int(clamp(_heal_amount, 0, _member_hp))

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
	is_hero = _data["v6"]
	is_commander = _data["v7"]
	squad_ability_idx = _data["v8"]
	range_fire_mode = _data["v9"]
	extra = _data["extra"]
	
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
	_data["v6"] = is_hero
	_data["v7"] = is_commander
	_data["v8"] = squad_ability_idx
	_data["v9"] = range_fire_mode
	_data["extra"] = extra
	return _data
	













