extends Control
class_name MiniMap

export var cam_pos :bool = true
export (Array, PackedScene) var tile_scenes :Array
export var rotation_rad :float
export var offset :Vector2

var _spawned_tiles :Dictionary = {} # { Vector2 : Tile2D }
var _tile_map_data :TileMapFileData

onready var _viewport :Viewport = $ViewportContainer/Viewport
onready var _map :Node2D = $ViewportContainer/Viewport/map
onready var _nine_patch_rect_2 = $NinePatchRect2

func _ready():
	set_process(true)
	set_physics_process(false)
	_viewport.size = rect_size
	_nine_patch_rect_2.visible = cam_pos
	
func _process(delta):
	_map.position = (rect_size / 2) - offset.rotated(rotation_rad) + Vector2(0, -30)
	_map.rotation = rotation_rad
	
func load_data_map(data: TileMapFileData):
	_tile_map_data = data
	
	_clean()
	_spawn_tiles()
	
func get_viewport() -> Viewport:
	return _viewport
	
func update_spawned_tile(data :TileMapData):
	var _spawned_tile :Tile2D = _spawned_tiles[data.id]
	
	# remove old
	_spawned_tile.queue_free()
	_spawned_tiles.erase(data.id)
	
	# spawn new
	var tile :Tile2D = _spawn_tile(data)
	_spawned_tiles[data.id] = tile
	
func _spawn_tiles():
	for i in _tile_map_data.tiles:
		_spawned_tiles[i.id] = _spawn_tile(i)
	
func _spawn_tile(data :TileMapData) -> Tile2D:
	var tile :Tile2D = tile_scenes[data.scene_idx].instance()
	tile.rotation_rad = rotation_rad
	tile.name = 'tile_2d_%s' % data.id
	tile.position = data.id * 10 # <- tile size
	_map.add_child(tile)
	return tile
	
func _clean():
	for child in _map.get_children():
		_map.remove_child(child)
		child.queue_free()
		
	_spawned_tiles.clear()






