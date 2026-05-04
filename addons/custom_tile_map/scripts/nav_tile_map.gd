extends Node
class_name NavTileMap

# faster way to get id
var _navigation_ids :Dictionary = {} # {int:[ Vector2:int ]}
var _navigation_pos :Dictionary = {} # {Vector2:Vector3}

# int as key is LAYER of naviagtion
# for ex 0:ground, 1:wall, 2:sea
onready var _navigations :Dictionary = {} # {int:AStar2D}

func _ready():
	set_process(false)
	set_physics_process(false)
	
func load_data_nav(navigation_datas :Dictionary):
	_clean()
	
	for layer in navigation_datas.keys():
		_load_data_nav(layer, navigation_datas[layer])
		
func is_nav_enable(layer_id :int, id :Vector2) -> bool:
	if _get_navigation_id(layer_id, id) == -1:
		return false
	
	return not _navigations[layer_id].is_point_disabled()
	
func enable_nav_tile(layer_id :int, id :Vector2, enable :bool):
	var navigation_id :int = _get_navigation_id(layer_id, id)
	if navigation_id != -1:
		_enable_nav_tile(_navigations[layer_id], navigation_id, enable)
	
# param blocked_ids is usefull for 
# seting temporary blocked tile
# like ally unit in the way
func get_navigation(layer_id :int, start_id :Vector2, end_id :Vector2, blocked_ids :Array = []) -> PoolVector2Array:
	if not _navigations.has(layer_id):
		return PoolVector2Array([])
		
	var start :int = _get_navigation_id(layer_id, start_id)
	var end :int = _get_navigation_id(layer_id, end_id)
	if start == -1 or end == -1:
		return PoolVector2Array([])
		
	return _get_navigation(_navigations[layer_id], start, end, blocked_ids) # [ Vector2 ]
	
func get_pos_v3(id :Vector2) -> Vector3:
	if not _navigation_pos.has(id):
		return Vector3.ZERO
		
	return _navigation_pos[id]
	
func _load_data_nav(layer_id :int, navigation_map :Array):
	if not _navigations.has(layer_id):
		_navigations[layer_id] = AStar2D.new()
		_navigation_ids[layer_id] = {}
		
	var _navigation :AStar2D = _navigations[layer_id]
	var _navigation_id :Dictionary = _navigation_ids[layer_id]
	
	_maping_ids(_navigation_id, navigation_map)
	_add_point(_navigation, navigation_map)
	_connect_point(_navigation, navigation_map)
	_set_obstacle(_navigation, navigation_map)
	
# if return were -1 = not found
func _get_navigation_id(layer_id :int, id :Vector2) -> int:
	if not _navigation_ids.has(layer_id):
		return -1
		
	if not _navigation_ids[layer_id].has(id):
		return -1
	
	return _navigation_ids[layer_id][id]
	
func _get_navigation(_nav :AStar2D, start :int, end :int, _blocked_nav_ids :Array) -> PoolVector2Array:
	var paths :PoolVector2Array = PoolVector2Array([])
	if not _nav.has_point(start):
		return paths
		
	if not _nav.has_point(end):
		return paths
		
	var _restored_disabled_point :Array = []
	
	# blocked tile
	for navigation_id in _blocked_nav_ids:
		var has_point :bool = _nav.has_point(navigation_id)
		var is_already_disabled :bool = _nav.is_point_disabled(navigation_id)
		if has_point and not is_already_disabled:
			_restored_disabled_point.append(navigation_id)
			_nav.set_point_disabled(navigation_id, true)
		
	# get path with blocked tiles
	paths = _nav.get_point_path(start, end)
	
	# open blocked tile
	for navigation_id in _restored_disabled_point:
		_nav.set_point_disabled(navigation_id, false)
		
	return paths
	
func _add_point(nav :AStar2D, data :Array):
	for i in data:
		var x :NavigationData = i
		nav.add_point(x.navigation_id, x.id)
		
func _maping_ids(_navigation_id :Dictionary, data :Array):
	for i in data:
		var x :NavigationData = i
		_navigation_id[x.id] = x.navigation_id
		_navigation_pos[x.id] = x.pos
		
func _connect_point(nav :AStar2D, data :Array):
	for i in data:
		var x :NavigationData = i
		for next_id in x.neighbors:
			nav.connect_points(x.navigation_id, next_id, false)
		
func _set_obstacle(nav :AStar2D, data :Array):
	for i in data:
		var x :NavigationData = i
		_enable_nav_tile(nav, x.navigation_id, x.enable)
	
func _enable_nav_tile(nav :AStar2D, navigation_id :int, enable :bool = true):
	if nav.has_point(navigation_id):
		nav.set_point_disabled(navigation_id, not enable)
		
func _clean():
	for layer_id in _navigations.keys():
		_navigations[layer_id].clear()
		
	for layer_id in _navigation_ids.keys():
		_navigation_ids[layer_id].clear()
		
	_navigations.clear()
	_navigation_ids.clear()
	_navigation_pos.clear()
	
	
	





