extends Node
class_name NavTileMap

var _navigation_datas :Array # as refrences

# faster way to get id
var _navigation_ids :Dictionary = {} # {int:[ Vector2:int ]}
var _navigation_pos :Dictionary = {} # {Vector2:Vector3}

# int as key is LAYER of naviagtion
# for ex 0:ground, 1:wall, 2:sea
onready var _navigations :Array = [] # [(index as LAYER_ID) [ AStar2D ]]

func _ready():
	set_process(false)
	set_physics_process(false)
	
func load_data_nav(navigation_datas :Array):
	_navigation_datas = navigation_datas
	_clean()
	
	var layer = 0
	for data in navigation_datas:
		_load_data_nav(layer, data)
		layer += 1
		
func is_nav_enable(layer_id :int, id :Vector2) -> bool:
	if _get_navigation_id(layer_id, id) == -1:
		return false
	
	return not _navigations[layer_id].is_point_disabled()
	
func enable_nav_tile(layer_id :int, id :Vector2, enable :bool):
	var navigation_id :int = _get_navigation_id(layer_id, id)
	if navigation_id != -1:
		_enable_nav_tile(_navigations[layer_id], navigation_id, enable)
		_navigation_datas[layer_id]
		
		# update to _navigation_datas refrences
		var nav_data :NavigationData
		for i in _navigation_datas[layer_id]:
			if i.id == id:
				nav_data = i
				break
		
		if not nav_data:
			return
			
		nav_data.enable = enable
			
# param blocked_ids is usefull for 
# seting temporary blocked tile
# like ally unit in the way
func get_navigation(layer_id :int, start_id :Vector2, end_id :Vector2, blocked_ids :Array = []) -> PoolVector2Array:
	if not _has_layer(layer_id):
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
	
func get_astar(layer_id :int) -> AStar2D:
	return _navigations[layer_id]
	
func get_navigation_id(layer_id :int, id :Vector2) -> int:
	return _get_navigation_id(layer_id, id)
	
func _load_data_nav(layer_id :int, navigation_map :Array):
	if not _has_layer(layer_id):
		_navigations.append(AStar2D.new())
		_navigation_ids[layer_id] = {}
		
	var _navigation :AStar2D = _navigations[layer_id]
	var _navigation_id :Dictionary = _navigation_ids[layer_id]
	
	_maping_ids(_navigation_id, navigation_map)
	_add_point(_navigation, navigation_map)
	_connect_point(_navigation, navigation_map, layer_id)
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
		
func _connect_point(nav :AStar2D, data :Array, layer_id:int):
	for i in data:
		var x :NavigationData = i
		var neighbors :Array = TileMapUtils.get_directions() if x.neighbor_mode == 0 else TileMapUtils.ARROW_DIRECTIONS
		for id in neighbors:
			var next_id :Vector2 = id + x.id
			if not _navigation_ids[layer_id].has(next_id):
				continue
				
			var nex_nav_id :int = _navigation_ids[layer_id][next_id]
			if nav.has_point(nex_nav_id):
				nav.connect_points(x.navigation_id, nex_nav_id, false)
		
func _set_obstacle(nav :AStar2D, data :Array):
	for i in data:
		var x :NavigationData = i
		_enable_nav_tile(nav, x.navigation_id, x.enable)
	
func _enable_nav_tile(nav :AStar2D, navigation_id :int, enable :bool = true):
	if nav.has_point(navigation_id):
		nav.set_point_disabled(navigation_id, not enable)
		
func _clean():
	for _navigation in _navigations:
		_navigation.clear()
		
	for layer_id in _navigation_ids.keys():
		_navigation_ids[layer_id].clear()
		
	_navigations.clear()
	_navigation_ids.clear()
	_navigation_pos.clear()
	
func _has_layer(id) -> bool:
	return id >= 0 and id < _navigations.size()





