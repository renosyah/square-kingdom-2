extends Node
class_name TilePositionManager

var _pending_update :Array = [] # [ Vector2(from), Vector2(to), BaseTileUnit, 0 ]
var _tile_map_unit_positions :Dictionary = {} # {Vector2:[ BaseTileUnit ] }

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
	
func add_to_position(unit :BaseTileUnit, current_tile:Vector2):
	_pending_update.append([unit, Vector2.ZERO, current_tile, 1])
	#_add_to_position(unit, current_tile)
	
func update_position(unit :BaseTileUnit, from:Vector2, to:Vector2):
	_pending_update.append([unit, from, to, 2])
	#_update_position(unit, from, to)
	
func remove_from_position(unit :BaseTileUnit, current_tile:Vector2):
	_pending_update.append([unit, current_tile, Vector2.ZERO, 3])
	#_remove_from_position(unit, current_tile)
	
func _add_to_position(unit :BaseTileUnit, current_tile:Vector2):
	_tile_map_unit_positions[current_tile].append(unit)
	
func _update_position(unit :BaseTileUnit, from:Vector2, to:Vector2):
	_remove_from_position(unit, from)
	_add_to_position(unit, to)
	
func _remove_from_position(unit :BaseTileUnit, current_tile:Vector2):
	_tile_map_unit_positions[current_tile].erase(unit)
		
func get_positions() -> Dictionary:
	return _tile_map_unit_positions

func init_position(size :int):
	# initiated empty positions
	var tiles :Array = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(),
		Vector2.ZERO, size
	) + [Vector2.ZERO]
	
	for id in tiles:
		_tile_map_unit_positions[id] = []

