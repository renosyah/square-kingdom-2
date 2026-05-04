extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var editable_tile_map = $editable_tile_map
onready var clickable_floor = $clickable_floor
onready var highlights = $highlights

var nav :NavTileMap
var tile_highlights :Array = []

func _ready():
	ui.random.connect("pressed", self, "_on_random_button_press")
	ui.nav_toggle.connect("pressed", self, "_on_nav_toggle_button_press")
	ui.movable_camera_ui.target = movable_camera
	editable_tile_map.load_data_map(Global.current_tile_map_file_data, true)

func _process(delta):
	var pos = movable_camera.translation * Vector3(1,0,1)
	clickable_floor.translation = pos
	ui.minimap.rotation_rad = movable_camera.rotation.y
	ui.minimap.offset = Vector2(pos.x, pos.z) * 10
	
func randomize_map_data(untouch :Array = [], _seed :int = rand_range(-100, 100)):
	var map_data :TileMapFileData = Global.current_tile_map_file_data
	
	var blocked = []
	var noise = OpenSimplexNoise.new()
	var rng = RandomNumberGenerator.new()
	rng.seed = _seed
	
	noise.seed = _seed
	noise.octaves = 3
	noise.period = 12.0
	noise.persistence = 0.856
	noise.lacunarity = 1.745
	
	for i in map_data.tiles:
		var x :TileMapData = i
		
		if x.id in untouch:
			x.scene_idx = 0
			continue
		
		var value = 2 * abs(noise.get_noise_2dv(x.id))
		if value > 0.4:
			x.scene_idx = 0
			
			if rng.randf() < 0.2:
				x.scene_idx = 4
				blocked.append(x.id)
				
		elif value > 0.3:
			x.scene_idx = 0
			
			if rng.randf() < 0.4:
				x.scene_idx = 3
				blocked.append(x.id)
				
		elif value > 0.2:
			x.scene_idx = 0
			
		elif value > 0.1:
			x.scene_idx = 1
			
		elif value <= 0.1:
			x.scene_idx = 2
			blocked.append(x.id)
			
		elif value < 0.0:
			x.tile_type = 2
			blocked.append(x.id)
			
	for i in map_data.navigations[0]:
		i.enable = not (i.id in blocked)
		
func _on_random_button_press():
	randomize_map_data()
	editable_tile_map.load_data_map(Global.current_tile_map_file_data, true)
	ui.minimap.load_data_map(Global.current_tile_map_file_data)
	
func _on_nav_toggle_button_press():
	highlights.visible = not highlights.visible
	
func _on_editable_tile_map_on_map_ready():
	nav = editable_tile_map.get_nav_tile_map()
	
	_clear_nav()
	for i in Global.current_tile_map_file_data.navigations[0]:
		var n :NavigationData = i
		var h = preload("res://assets/tile_highlight/tile_highlight.tscn").instance()
		highlights.add_child(h)
		h.enable(n.enable)
		h.translation = n.pos
		tile_highlights.append(h)

func _clear_nav():
	for i in tile_highlights:
		i.queue_free()
		
	tile_highlights.clear()

func _on_clickable_floor_on_floor_clicked(pos):
	var tile :TileMapData = editable_tile_map.get_closes_tile(pos)
