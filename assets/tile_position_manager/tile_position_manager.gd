extends Node
class_name TilePositionManager

export var uses_pending :bool = false
var _pending_update :Array = [] # [ Vector2(from), Vector2(to), BaseTileUnit, 0 ]
var _tile_map_unit_positions :Dictionary = {} # {Vector2:[ BaseTileUnit ] }
var _unit_indexing :Dictionary = {} #{unit:int}

func _ready():
	set_process(not uses_pending)

func _process(delta):
	if _pending_update.empty():
		return
	
	for i in _pending_update:
		match i[3]:
			1:
				_add_to_position(i[0], i[2])
			2:
				_update_position(i[0], i[1], i[2])
			3:
				_remove_from_position(i[0], i[1])
		
	_pending_update.clear()
	
# register 
func add_to_position(unit, current_tile:Vector2):
	if uses_pending:
		_pending_update.append([unit, Vector2.ZERO, current_tile, 1])
		return
		
	_add_to_position(unit, current_tile)
	
func update_position(unit, from:Vector2, to:Vector2):
	if uses_pending:
		_pending_update.append([unit, from, to, 2])
		return
		
	_update_position(unit, from, to)
	
# remove permanent
func remove_from_position(unit, current_tile:Vector2):
	if uses_pending:
		_pending_update.append([unit, current_tile, Vector2.ZERO, 3])
		return
		
	_unit_indexing.erase(unit)
	_remove_from_position(unit, current_tile)
	
func _add_to_position(unit, current_tile:Vector2):
	_unit_indexing[unit] = _tile_map_unit_positions[current_tile].size()
	_tile_map_unit_positions[current_tile].append(unit)
	
func _update_position(unit, from:Vector2, to:Vector2):
	_remove_from_position(unit, from)
	_add_to_position(unit, to)
	
func _remove_from_position(unit, current_tile:Vector2):
	_tile_map_unit_positions[current_tile].erase(unit)
	
	for current_size in _tile_map_unit_positions[current_tile].size():
		var u = _tile_map_unit_positions[current_tile][current_size]
		_unit_indexing[u] = current_size
		
func get_positions() -> Dictionary:
	return _tile_map_unit_positions
	
func get_unit_indexing() -> Dictionary:
	return _unit_indexing

func init_position(size :int):
	# initiated empty positions
	var tiles :Array = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(),
		Vector2.ZERO, size
	) + [Vector2.ZERO]
	
	for id in tiles:
		_tile_map_unit_positions[id] = []

