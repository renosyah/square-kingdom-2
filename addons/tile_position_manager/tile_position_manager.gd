extends Node
class_name TilePositionManager

var _tile_map_unit_positions :Dictionary = {} # {Vector2:[ BaseTileUnit ] }

func get_positions() -> Dictionary:
	return _tile_map_unit_positions

func init_position(size :int):
	# initiated empty positions
	var tiles :Array = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(),
		Vector2.ZERO, size
	)
	for id in tiles:
		_tile_map_unit_positions[id] = []

func units_in_position(id:Vector2) -> Array:
	if not _tile_map_unit_positions.has(id):
		return []
	
	return _tile_map_unit_positions[id]

func add_to_position(unit :BaseTileUnit):
	var current_tile :Vector2 = unit.current_tile
	if not _tile_map_unit_positions.has(current_tile):
		_tile_map_unit_positions[current_tile] = []
		
	var pos_datas:Array = _tile_map_unit_positions[current_tile]
	if not pos_datas.has(unit):
		pos_datas.append(unit)
		
func update_position(unit :BaseTileUnit, from:Vector2, to:Vector2):
	if _tile_map_unit_positions.has(from):
		_tile_map_unit_positions[from].erase(unit)
		
	if not _tile_map_unit_positions.has(to):
		_tile_map_unit_positions[to] = []
		
	_tile_map_unit_positions[to].append(unit)

func remove_from_position(unit :BaseTileUnit):
	if _tile_map_unit_positions[unit.current_tile].has(unit):
		_tile_map_unit_positions.erase(unit)
