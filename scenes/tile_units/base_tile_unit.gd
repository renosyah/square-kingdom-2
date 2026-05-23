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
signal on_unit_dead(unit)

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
export var spotting_range :int = 1
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
var is_dead :bool = false
# for nav and targeting
# unit_position is refrence
# change value it also change the root variable value
# for tracking purposes
var nav_layer :int
var nav :NavTileMap
var unit_position :Dictionary = {} # {Vector2 : [BaseTileUnit]}

var chase_enemy = null # cycle warning set to null
var enemy = null # cycle warning set to null
var attack_move :bool
var spotting_area :Array

var _has_enemy :bool # for easier

# multiplayer data to sync
puppet var _puppet_current_tile :Vector2
puppet var _puppet_translation :Vector3

func _ready():
	update_spotting()
	Global.connect("on_global_tick", self, "_on_global_tick")

# set chase_enemy = UNIT
# chase_target()
# move_to will set chase_enemy to NULL
func chase_target():
	if is_instance_valid(chase_enemy):
		# give up the chase if
		# diffrent nav layer
		# no path to it
		if chase_enemy.nav_layer != nav_layer:
			chase_enemy = null
			return
			
		if _is_in_range(chase_enemy):
			enemy = chase_enemy
			_has_enemy = true
			_on_enemy_set()
			return
			
		_move_to(chase_enemy.current_tile)
		if _paths.empty():
			chase_enemy = null
			
func move_to(tile_id :Vector2):
	chase_enemy = null
	_move_to(tile_id)
	
func _move_to(tile_id :Vector2):
	if is_dead:
		return
		
	if not _is_master or not is_instance_valid(nav):
		return
		
	_has_enemy = false
	enemy = null
	
	var v :Array = _get_tile_path(tile_id)
	if v.empty():
		return
		
	_last_to = global_position
	
	_is_moving = true
	_paths.clear()
	_paths.append_array(v)
	
	if attack_move:
		update_spotting()
		_scan_area()
		
func is_moving() -> bool:
	return _is_moving
	
func _get_tile_path(to :Vector2) -> Array:
	var paths :Array = []
	var p :PoolVector2Array = nav.get_navigation(nav_layer, current_tile, to, [])
	for id in p:
		paths.append(TileUnitPath.new(id, nav.get_pos_v3(id)))
		
	paths.pop_front()
	
	return paths
	
func click():
	if not _is_selected:
		return
		
	emit_signal("on_unit_clicked", self)
	
func stop(use_rpc :bool = true):
	if _is_master or not use_rpc:
		_stop()
		return
		
	# call stop, tell master to stop from other peer
	rpc_id(get_network_master(), "_stop")
	
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
	
remote func _stop():
	_is_moving = false
	_paths.clear()
	
func sync_update() -> void:
	if not is_dead:
		.sync_update()
	
	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_position)
		rset_unreliable("_puppet_current_tile", current_tile)
		
func last_sync_update() -> void:
	.last_sync_update()
	
	if not is_dead and _is_master and _is_online:
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
	
func _on_enemy_in_range(_delta :float, _pos :Vector3, _enemy_pos :Vector3):
	pass
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if is_dead:
		return
		
	translation = translation.linear_interpolate(_puppet_translation, 25 * delta) 
	
	# make sure only send updated
	# this make sure value changes only once
	if current_tile != _puppet_current_tile:
		var old = current_tile
		current_tile = _puppet_current_tile
		_on_current_tile_updated(old, current_tile)
	
# for active enemy spotting
func _on_global_tick():
	if _is_master and not _is_moving:
		
		# have task to chase enemy
		# go get them
		if _chase_on_iddle():
			return
			
		_scan_area()
	
func _on_current_tile_updated(from_id :Vector2, to_id :Vector2):
	emit_signal("on_current_tile_updated", self, from_id, to_id)
	
	update_spotting()
	
	if not _is_master:
		return
		
	if is_instance_valid(chase_enemy):
		# stop the chase
		# if chase_enemy is dead
		if chase_enemy.is_dead:
			chase_enemy = null
			stop(false)
			return
			
		if _is_in_range(chase_enemy):
			enemy = chase_enemy
			_has_enemy = true
			_on_enemy_set()
			return
		
	if attack_move:
		_scan_area()
	
func _on_finish_travel(from_id :Vector2, to_id :Vector2):
	emit_signal("on_finish_travel", self, from_id, to_id)
	
	update_spotting()
	
	if _is_master:
		_scan_area()
	
func _chase_on_iddle() -> bool:
	if is_instance_valid(chase_enemy):
		# stop the chase
		# continue scan area
		if chase_enemy.is_dead:
			chase_enemy = null
			return false
			
		if not _is_in_range(chase_enemy):
			chase_target()
			return true
			
	return false
	
func update_spotting():
	spotting_area = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.ARROW_DIRECTIONS, current_tile, spotting_range
	) + [current_tile]
	
func _scan_area():
	if unit_position.empty():
		return
		
	if _has_enemy:
		return
		
	for pos in spotting_area:
		if not unit_position.has(pos):
			continue
			
		var unit_positions :Array = unit_position[pos]
		if unit_positions.empty():
			continue
			
		if _check_enemy_in_position(unit_positions):
			_has_enemy = true
			_on_enemy_set()
			return
			
func _check_enemy_in_position(datas :Array) -> bool:
	for unit in datas:
		if not is_instance_valid(unit):
			continue
			
		if unit.is_dead or unit.nav_layer != nav_layer:
			continue
			
		if unit.team != team:
			enemy = unit
			return true
			
	return false

func _is_in_range(_unit) -> bool:
	if _unit.is_dead:
		return false
		
	return _unit.current_tile in spotting_area
	
func _on_enemy_set():
	pass
	
func set_dead(use_rpc :bool = true):
	if is_dead:
		return
	
	if use_rpc:
		rpc("_set_dead")
	else:
		_set_dead()
	is_dead = true # safeguard, make faster
	
func on_dead():
	emit_signal("on_unit_dead", self)

remotesync func _set_dead():
	is_dead = true
	on_dead()

# just for decoration
func clone_mesh() -> Spatial:
	return null








