extends BaseData
class_name GrandMapFileManifest

var map_name :String
var map_size :int
var battle_map_size :int
var map_image_file_path :String
var map_file_path :String

func from_dictionary(_data : Dictionary):
	map_name = _data["a"]
	map_size = _data["b"]
	battle_map_size = _data["c"]
	map_image_file_path = _data["d"]
	map_file_path = _data["e"]

func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	_data["a"] = map_name
	_data["b"] = map_size
	_data["c"] = battle_map_size
	_data["d"] = map_image_file_path
	_data["e"] = map_file_path
	return _data
