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
export var pos :Vector3

# tile unit data
export var network_id :int
export var player_id :String
export var team :int
export var color_idx :int
export var speed :float = 2
export var spotting_range :int = 1

# squad data
export var squad_type :int
export var member_scene_idx :int
export var can_attack :bool = true
export var turning_speed :float = 8
export var attack_speed :float = 0.8
export var formation_density :float = 0.35
export var icon_idx :int
export var potrait_idx :int

# squad member
export var member_headgear_idx :int
export var member_armor_idx :int
export var member_shield_idx :int
export var member_melee_weapon_idx :int
export var member_range_weapon_idx :int
export var member_hp :int = 100
export var member_max_hp :int = 100
export var total_member :int = 9

func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	scene_idx = _data["a"]
	node_name = _data["a2"]
	current_tile = _data["a3"]
	pos = _data["a4"]
	squad_id = _data["a5"]
	squad_name = _data["a6"]
	description = _data["a7"]
	network_id = _data["b"]
	player_id = _data["c"]
	team = _data["d"]
	color_idx = _data["e"]
	speed = _data["f"]
	spotting_range = _data["f1"]
	squad_type = _data["f2"]
	member_scene_idx = _data["g"]
	can_attack = _data["i"]
	turning_speed = _data["j"]
	attack_speed = _data["k"]
	formation_density = _data["l"]
	icon_idx = _data["l1"]
	potrait_idx = _data["l2"]
	member_headgear_idx = _data["m"]
	member_armor_idx = _data["n"]
	member_shield_idx = _data["o"]
	member_melee_weapon_idx = _data["p"]
	member_range_weapon_idx = _data["q"]
	member_hp = _data["r"]
	member_max_hp = _data["s"]
	total_member = _data["t"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["a"] = scene_idx
	_data["a2"] = node_name
	_data["a3"] = current_tile
	_data["a4"] = pos
	_data["a5"] = squad_id
	_data["a6"] = squad_name
	_data["a7"] = description
	_data["b"] = network_id
	_data["c"] = player_id
	_data["d"] = team
	_data["e"] = color_idx
	_data["f"] = speed
	_data["f1"] = spotting_range
	_data["f2"] = squad_type
	_data["g"] = member_scene_idx
	_data["i"] = can_attack
	_data["j"] = turning_speed
	_data["k"] = attack_speed
	_data["l"] = formation_density
	_data["l1"] = icon_idx
	_data["l2"] = potrait_idx
	_data["m"] = member_headgear_idx
	_data["n"] = member_armor_idx
	_data["o"] = member_shield_idx
	_data["p"] = member_melee_weapon_idx
	_data["q"] = member_range_weapon_idx
	_data["r"] = member_hp
	_data["s"] = member_max_hp
	_data["t"] = total_member
	return _data
	













