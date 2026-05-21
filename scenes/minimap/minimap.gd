extends Control
class_name MiniMap

signal on_minimap_ready

export var cam_pos :bool = true
export (Array, PackedScene) var tile_scenes :Array
export var rotation_rad :float
export var offset :Vector2
export var tile_rotation_degree :float = -45

var _spawned_tiles :Dictionary = {} # { Vector2 : Tile2D }
var _tile_map_data :TileMapFileData

var _spawned_object :Dictionary = {} # {Spatial:Node2D}

onready var _viewport :Viewport = $ViewportContainer/Viewport
onready var _map :Node2D = $ViewportContainer/Viewport/map
onready var _nine_patch_rect_2 = $NinePatchRect2
onready var _batch_spawner = $batch_spawner

func _ready():
	set_physics_process(false)
	_viewport.size = rect_size
	_nine_patch_rect_2.visible = cam_pos
	
func _process(_delta):
	_map.position = (rect_size / 2) - offset.rotated(rotation_rad) + Vector2(0, 5)
	_map.rotation = rotation_rad
	
	for obj in _spawned_object.keys():
		var pos = Vector2(obj.global_position.x, obj.global_position.z) * 10
		var tile = _spawned_object[obj]
		tile.position = pos
	
func load_data_map(data: TileMapFileData):
	_tile_map_data = data
	set_process(false)
	
	_clean()
	_batch_spawner.start(_tile_map_data.tiles, 16)
	
func add_object(obj :Spatial, color :Color):
	var tile = preload("res://scenes/minimap/object_2d/object_2d.tscn").instance()
	tile.modulate = color
	_map.add_child(tile)
	_spawned_object[obj] = tile
	
func remove_object(obj :Spatial):
	_spawned_object[obj].queue_free()
	_spawned_object.erase(obj)
	
func _on_batch_spawner_on_spawn(data :TileMapData):
	_spawned_tiles[data.id] = _spawn_tile(data)
	
func _on_batch_spawner_on_finish():
	set_process(true)
	emit_signal("on_minimap_ready")
	
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
	
func _spawn_tile(data :TileMapData) -> Tile2D:
	var tile :Tile2D = tile_scenes[data.scene_idx].instance()
	tile.tile_rotation_degree = tile_rotation_degree
	tile.name = 'tile_2d_%s' % data.id
	tile.position = data.id * 10 # <- tile size
	_map.add_child(tile)
	return tile
	
func _clean():
	for child in _map.get_children():
		_map.remove_child(child)
		child.queue_free()
		
	_spawned_tiles.clear()











