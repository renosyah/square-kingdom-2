extends MarginContainer
class_name MiniMap

export (Array, PackedScene) var tile_scenes :Array
export var rotation_rad :float
export var offset :Vector2

var _spawned_tiles :Dictionary = {} # { Vector2 : Tile2D }
var _tile_map_data :TileMapFileData

onready var map = $ViewportContainer/Viewport/map

func _ready():
	set_process(true)
	set_physics_process(false)
	
func _process(delta):
	map.position = (rect_size / 2) - offset.rotated(rotation_rad)
	map.rotation = rotation_rad
	
func load_data_map(data: TileMapFileData):
	_tile_map_data = data
	_clean()
	_spawn_tiles()
	
func _spawn_tiles():
	for i in _tile_map_data.tiles:
		var data :TileMapData = i
		_spawned_tiles[data.id] = _spawn_tile(data)
	
func _spawn_tile(data :TileMapData) -> Tile2D:
	var tile :Tile2D = tile_scenes[data.scene_idx].instance()
	tile.name = 'tile_2d_%s' % data.id
	tile.position = data.id * 16 # <- tile size with offset
	map.add_child(tile)
	return tile
	
func _clean():
	for key in _spawned_tiles.keys():
		var tile = _spawned_tiles[key]
		tile.queue_free()
		
	_spawned_tiles.clear()
