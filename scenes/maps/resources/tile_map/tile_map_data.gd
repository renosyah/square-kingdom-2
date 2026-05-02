extends Resource
class_name TileMapData

var id :Vector2
var pos :Vector3

# store only index not scene path
# get index from const scenes
var scene_idx :int

# store only int value
# 0:[WALKABLE]
# 1:[NON-WALKABLE]
var tile_type :int

# store only index not float value of rotation
# 0:0, 1:90, 2:180, 3:270
var rotation_idx :int

func from_dictionary(_data : Dictionary):
	id = _data["a"]
	pos = _data["b"]
	scene_idx = _data["c"]
	tile_type = _data["d"]
	rotation_idx = _data["e"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	_data["a"] = id
	_data["b"] = pos
	_data["c"] = scene_idx
	_data["d"] = tile_type
	_data["e"] = rotation_idx
	return _data
