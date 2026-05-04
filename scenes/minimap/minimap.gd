extends Control
class_name MiniMap

export (Array, PackedScene) var tile_scenes :Array
export var rotation_rad :float
export var offset :Vector2

var _spawned_tiles :Dictionary = {} # { Vector2 : Tile2D }
var _tile_map_data :TileMapFileData
var _click_position :Vector2

onready var _viewport = $ViewportContainer/Viewport
onready var _map = $ViewportContainer/Viewport/map
onready var _input_detection = $input_detection

func _ready():
	set_process(true)
	set_physics_process(false)
	_viewport.size = rect_size
	
func _process(delta):
	_map.position = (rect_size / 2) - offset.rotated(rotation_rad)
	_map.rotation = rotation_rad
	
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
	tile.position = data.id * 10 # <- tile size
	_map.add_child(tile)
	return tile
	
func _clean():
	for key in _spawned_tiles.keys():
		var tile = _spawned_tiles[key]
		tile.queue_free()
		
	_spawned_tiles.clear()

func _on_ViewportContainer_gui_input(event):
	_input_detection.check_input(event)

func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		var tile :TileMapData = _get_closes_tile(event.position)
		if is_instance_valid(tile):
			emit_signal("on_minimap_clicked", event.position, tile)
		
func _get_closes_tile(from :Vector2) -> TileMapData:
	var tiles :Array = _tile_map_data.tiles
	if tiles.empty():
		return null
		
	var current :TileMapData = tiles[0]
	var tile_size :Vector2 = Vector2(10, 10) # <- tile size
	var modifier :Vector2 = _map.global_position
	for i in tiles:
		if i == current:
			continue
			
		var dist_1 = ((current.id * tile_size) + modifier).distance_squared_to(from)
		var dist_2 = ((i.id * tile_size) + modifier).distance_squared_to(from)
		if dist_2 < dist_1:
			current = i
			
	return current # TileMapData





