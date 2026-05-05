extends Control
class_name MiniMap

export (Array, PackedScene) var tile_scenes :Array
export var rotation_rad :float
export var offset :Vector2

var _tile_map_data :TileMapFileData
var _click_position :Vector2

onready var _viewport :Viewport = $ViewportContainer/Viewport
onready var _map :Node2D = $ViewportContainer/Viewport/map

func _ready():
	set_process(true)
	set_physics_process(false)
	_viewport.size = rect_size
	
func _process(delta):
	_map.position = (rect_size / 2) - offset.rotated(rotation_rad) + Vector2(0, -30)
	_map.rotation = rotation_rad
	
func load_data_map(data: TileMapFileData):
	_tile_map_data = data
	
	_clean()
	_spawn_tiles()
	
func _spawn_tiles():
	for i in _tile_map_data.tiles:
		_spawn_tile(i)
	
func _spawn_tile(data :TileMapData) -> Tile2D:
	var tile :Tile2D = tile_scenes[data.scene_idx].instance()
	tile.name = 'tile_2d_%s' % data.id
	tile.position = data.id * 10 # <- tile size
	_map.add_child(tile)
	return tile
	
func _clean():
	for child in _map.get_children():
		_map.remove_child(child)
		child.queue_free()







