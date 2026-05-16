extends BaseData
class_name SquadData

export var network_id :int
export var player_id :String
export var team :int
export var color_idx :int
export var speed :float = 2
export var hp :int = 100
export var max_hp :int = 100
export var has_range_weapon :bool = false
export var attack_damage :int = 1
export var can_attack :bool = true
export var turning_speed :float = 8
export var formation_density :float = 0.25

export var member_scene_idx :int


func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	return _data
	
func to_bytes() -> PoolByteArray:
	return var2bytes(to_dictionary())
	
func from_bytes(bytes :PoolByteArray):
	from_dictionary(bytes2var(bytes))
