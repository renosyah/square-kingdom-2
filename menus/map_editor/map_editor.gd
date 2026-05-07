extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var editable_tile_map = $editable_tile_map
onready var clickable_floor = $clickable_floor
onready var highlights = $highlights

var nav :NavTileMap

func _ready():
	ui.random.connect("pressed", self, "_on_random_button_press")
	ui.nav_toggle.connect("pressed", self, "_on_nav_toggle_button_press")
	ui.movable_camera_ui.target = movable_camera
	ui.movable_camera_minimap.target = movable_camera
	editable_tile_map.load_data_map(Global.current_tile_map_file_data, true)

func _process(delta):
	var pos = movable_camera.translation * Vector3(1,0,1)
	clickable_floor.translation = pos
	ui.minimap.rotation_rad = movable_camera.rotation.y
	ui.minimap.offset = Vector2(pos.x, pos.z) * 10
	
func randomize_map_data(untouch :Array = [], _seed :int = rand_range(-100, 100)):
	var map_data :TileMapFileData = Global.current_tile_map_file_data
	var blocked = []
	var rng = RandomNumberGenerator.new()
	rng.seed = _seed
	
	var noise = OpenSimplexNoise.new()
	noise.seed = _seed
	noise.octaves = 3
	noise.period = 12.0
	noise.persistence = 0.856
	noise.lacunarity = 1.745
	
	var trees = [4,5,6,7]
	var rocks = [8,9,10]
	var rotate = [0,1,2]
	
	for i in map_data.tiles:
		var x :TileMapData = i
		x.scene_idx = 0
		
		if x.id in untouch:
			continue
			
		var value = 2 * abs(noise.get_noise_2dv(x.id))
		if value > 0.4 and value < 0.5:
			if rng.randf() < 0.2:
				x.rotation_idx = Utils.get_random(rng, rotate)
				x.scene_idx = Utils.get_random(rng, rocks)
				blocked.append(x.id)
				
		elif value > 0.3 and value < 0.4:
			if rng.randf() < 0.4:
				x.rotation_idx = Utils.get_random(rng, rotate)
				x.scene_idx = Utils.get_random(rng, trees)
				blocked.append(x.id)
				
		elif value > 0.2 and value < 0.3:
			x.scene_idx = 1
		elif value > 0.1 and value < 0.2:
			x.scene_idx = 2
		elif value < 0.1:
			x.scene_idx = 3
			blocked.append(x.id)
			
	for i in map_data.navigations[0]:
		i.enable = not (i.id in blocked)
		
func display_selected_nav(layer_id :int):
	for i in highlights.get_children():
		highlights.remove_child(i)
		i.queue_free()
		
	for i in Global.current_tile_map_file_data.navigations[layer_id]:
		var n :NavigationData = i
		var h = preload("res://assets/tile_highlight/tile_highlight.tscn").instance()
		highlights.add_child(h)
		h.set_text("%s\n%s" % [n.id, n.navigation_id])
		h.enable(n.enable)
		h.translation = n.pos
		
func _on_random_button_press():
	randomize_map_data()
	editable_tile_map.load_data_map(Global.current_tile_map_file_data, true)
	ui.minimap.rotation_rad = -45
	ui.minimap.load_data_map(Global.current_tile_map_file_data)
	
func _on_nav_toggle_button_press():
	highlights.visible = not highlights.visible
	
func _on_editable_tile_map_on_map_ready():
	nav = editable_tile_map.get_nav_tile_map()
	display_selected_nav(0)
	
func _on_clickable_floor_on_floor_clicked(pos):
	var tile :TileMapData = editable_tile_map.get_closes_tile(pos)

func _on_ui_on_tile_card_dropped(posv2 :Vector2, tile_data :TileMapData):
	var posv3 = Utils.screen_to_world(get_viewport().get_camera(), posv2, false, 4)
	
	var tile :TileMapData = editable_tile_map.get_closes_tile(posv3)
	tile_data.id = tile.id
	tile_data.pos = tile.pos
	
	editable_tile_map.update_spawned_tile(tile_data)
	
func _on_editable_tile_map_on_tile_updated(id, data, node):
	ui.minimap.update_spawned_tile(data)
	nav.enable_nav_tile(0, id, data.scene_idx in [0,1,2])
	display_selected_nav(0)

func _on_ui_on_nav_card_dropped(posv2, enable):
	var posv3 = Utils.screen_to_world(get_viewport().get_camera(), posv2, false, 4)
	var tile :TileMapData = editable_tile_map.get_closes_tile(posv3)
	nav.enable_nav_tile(0, tile.id, enable)
	display_selected_nav(0)




















