extends BaseData
class_name PlayerData

var player_network_id :int
var player_id :String
var player_name :String
var team :int = 1

func from_dictionary(_data : Dictionary):
	player_network_id = _data["a"]
	player_id = _data["b"]
	player_name = _data["c"]
	team = _data["d"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	_data["a"] = player_network_id
	_data["b"] = player_id
	_data["c"] = player_name
	_data["d"] = team
	return _data
