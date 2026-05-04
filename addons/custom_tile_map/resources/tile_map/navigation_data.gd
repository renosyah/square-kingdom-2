extends Resource
class_name NavigationData

var id :Vector2
var pos :Vector3

# store only array of id for AStar2D navigation
# want Vector2 ? get it from AStar2D.get_point_position()
var neighbors: Array #  [ int ]
var navigation_id :int
var enable: bool

func from_dictionary(_data : Dictionary):
	navigation_id = _data["a"]
	id = _data["b"]
	enable = _data["c"]
	neighbors = _data["d"]
	pos = _data["e"]
	
func to_dictionary() -> Dictionary :
	var data :Dictionary = {}
	data["a"] = navigation_id
	data["b"] = id
	data["c"] = enable
	data["d"] = neighbors
	data["e"] = pos
	return data
