extends BaseEntity
class_name BaseTileUnit

# this is entity that can sync in network enviroment
# only basic sync of positioning & rotation state on y axis
# because this is unit that using tile mechanic as its movement
# current tile also getting tracked
signal on_unit_spotted(unit)
signal on_unit_clicked(unit)
signal on_current_tile_updated(unit, from_id, to_id)
signal on_finish_travel(unit, last_id, current_id)

class TileUnitPath:
	var tile_id :Vector2
	var pos :Vector3
	
	func _init(a,b):
		tile_id = a
		pos = b
		
# info
export var player_id :String
export var unit_name :String
export var team :int = 0
export var color :Color = Color.white
export var speed :float = 1.4
export var margin :float = 0.15

var _is_moving :bool # block some function if this is true
var _is_selected :bool = true # allow this unit to be selected or not

var _last_tile :Vector2 # last tile leaved
var _last_to :Vector3 # las position leave
var _paths :Array # [TileUnitPath]

var _hidden :bool # permanent invisible
var _spotted :bool # visible or not, but be overide by _hidden
var _current_visible :bool # current state of visible, this dont set value to visible

var current_tile :Vector2

# for nav and targeting
# unit_position is refrence
# change value it also change the root variable value
# for tracking purposes
var nav_layer :int
var nav :NavTileMap

export var spotting_range :int = 1
export var enable_spotting :bool
var spotting_area :Array

# multiplayer data to sync
puppet var _puppet_current_tile :Vector2
puppet var _puppet_translation :Vector3

func move_to(tile_id :Vector2):
	_move_to(tile_id, true)
	
func _move_to(tile_id :Vector2, use_safe :bool):
	if not _is_master or not is_instance_valid(nav):
		return
	
	var v :Array = _get_tile_path(tile_id, use_safe)
	if v.empty():
		return
		
	_last_to = global_position
	
	_is_moving = true
	_paths.clear()
	_paths.append_array(v)
	
func has_next_path() -> bool:
	return not _paths.empty() and _paths.size() > 1
	
func next_tile() -> Vector2:
	return _paths[1].tile_id
	
func is_moving() -> bool:
	return _is_moving
	
func _get_tile_path(to :Vector2, use_safe :bool) -> Array:
	var paths :Array = []
	var p :PoolVector2Array = nav.get_navigation(nav_layer, current_tile, to, [], use_safe)
	for id in p:
		paths.append(TileUnitPath.new(id, nav.get_pos_v3(id)))
		
	if paths.size() >= 2:
		paths.pop_front()
	 
	return paths
	
func click():
	if not _is_selected or _hidden:
		return
		
	emit_signal("on_unit_clicked", self)
	
func stop(use_rpc :bool = true):
	if _is_master or not use_rpc:
		_stop()
		return
		
	# call stop, tell master to stop from other peer
	rpc_id(get_network_master(), "_stop")
	
remote func _stop():
	_is_moving = false
	_paths.clear()
	on_stop()
	
func on_stop():
	pass
	
# only mechanic for puppet side only
func set_spotted(v :bool):
	if not _is_master and not _hidden:
		_spotted = v
		_current_visible = _spotted
		
	if _current_visible:
		emit_signal("on_unit_spotted", self)
		
func set_hidden(v :bool):
	_hidden = v
	_current_visible = not _hidden

func set_selected(v :bool):
	_is_selected = v
	
func is_selected() -> bool:
	return _is_selected
	

	
func sync_update() -> void:
	.sync_update()
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_position)
		rset_unreliable("_puppet_current_tile", current_tile)
		
func last_sync_update() -> void:
	.last_sync_update()
	
	if _is_master and _is_online:
		rset("_puppet_translation", global_position)
		rset("_puppet_current_tile", current_tile)
		
func _follow_path_proccess(delta :float, pos :Vector3):
	# safeguard
	if not _is_moving:
		return
		
	if _paths.empty():
		_is_moving = false
		_on_finish_travel(_last_tile, current_tile)
		return
		
	var p :TileUnitPath = _paths.front()
	
	if pos.distance_squared_to(p.pos) <= (margin * margin):
		_last_tile = current_tile
		current_tile = p.tile_id
		
		_on_current_tile_updated(_last_tile, current_tile)
		
		_paths.pop_front()
		_last_to = p.pos
		return
		
	# procced to movement function
	_move_to_next_path(delta, pos, p.pos)
	
func _move_to_next_path(delta :float, pos :Vector3, to :Vector3):
	translation += pos.direction_to(to) * speed * delta
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	translation = translation.linear_interpolate(_puppet_translation, 25 * delta) 
	
	# make sure only send updated
	# this make sure value changes only once
	if current_tile != _puppet_current_tile:
		var old = current_tile
		current_tile = _puppet_current_tile
		_on_current_tile_updated(old, current_tile)
	
func _on_current_tile_updated(from_id :Vector2, to_id :Vector2):
	emit_signal("on_current_tile_updated", self, from_id, to_id)
	update_spotting()
	
func _on_finish_travel(from_id :Vector2, to_id :Vector2):
	emit_signal("on_finish_travel", self, from_id, to_id)
	update_spotting()
	
func update_spotting():
	if enable_spotting:
		spotting_area = TileMapUtils.get_adjacent_tiles(
			TileMapUtils.ARROW_DIRECTIONS, current_tile, spotting_range
		) + [current_tile]

# just for decoration
func clone_mesh() -> Spatial:
	return null








