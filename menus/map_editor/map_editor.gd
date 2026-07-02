extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var editable_tile_map = $editable_tile_map
onready var clickable_floor = $clickable_floor
onready var highlights = $highlights
onready var batch_spawner = $batch_spawner
onready var batch_despawner = $batch_despawner
onready var untouch_tiles = TileIndex.generate_spawn_points(Global.current_tile_map_manifest_data.map_size)

onready var setting :SettingData = Global.setting_data

var spawn_tiles :Array
var nav_tiles :Dictionary
var nav :NavTileMap

func _ready():
	Global.connect("on_setting_updated", self, "_on_setting_updated")
	
	var map_size :int = Global.current_tile_map_manifest_data.map_size
	ui.random.connect("pressed", self, "_on_random_button_press")
	ui.nav_toggle.connect("pressed", self, "_on_nav_toggle_button_press")
	
	ui.movable_camera_ui.target = movable_camera
	ui.movable_camera_ui.camera_limit_bound = Vector3(map_size, 0, map_size )
	ui.movable_camera_ui.detect_in_out = false
	
	ui.movable_camera_ui.move_speed = setting.camera_move_speed
	ui.movable_camera_ui.zoom_speed= setting.camera_zoom_speed
	
	ui.movable_camera_minimap.target = movable_camera
	ui.movable_camera_minimap.camera_limit_bound = Vector3(map_size, 0, map_size)
	ui.movable_camera_minimap.detect_in_out = false
	
	editable_tile_map.biom = 0
	editable_tile_map.tile_scenes = TileIndex.tiles
	editable_tile_map.load_data_map(Global.current_tile_map_file_data, true)
	
	ui.biom_buttons[0].disabled = true
	
	for idx in ui.biom_buttons.size():
		ui.biom_buttons[idx].connect("pressed", self, "_on_biom_button_press", [idx])
	
	
func _on_setting_updated(d :SettingData):
	ui.movable_camera_ui.move_speed = d.camera_move_speed
	ui.movable_camera_ui.zoom_speed= d.camera_zoom_speed
	
func _process(delta):
	var pos = movable_camera.global_transform.origin * Vector3(1,0,1)
	editable_tile_map.update_camera_location(Vector2(pos.x, pos.z).round())
	clickable_floor.translation = pos
	
	if ui.cam_rot_l.pressed:
		movable_camera.rotation_degrees.y -= setting.camera_rotation_speed * delta
		
	elif ui.cam_rot_r.pressed:
		movable_camera.rotation_degrees.y += setting.camera_rotation_speed * delta
	
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
	
	var trees = TileIndex.tile_names[TileIndex.trees]
	var rocks = TileIndex.tile_names[TileIndex.rocks]
	var rotates =TileIndex.tile_names[TileIndex.rotates]
	
	for i in map_data.tiles:
		var x :TileMapData = i
		x.scene_idx = TileIndex.tile_names[TileIndex.ground]
		var in_untouch = x.id in untouch
		
		var value = 2 * abs(noise.get_noise_2dv(x.id))
		if value > 0.4 and value < 0.5 and not in_untouch:
			if rng.randf() < 0.2:
				x.rotation_idx = Utils.get_random(rng, rotates)
				x.scene_idx = Utils.get_random(rng, rocks)
				blocked.append(x.id)
				
		elif value > 0.3 and value < 0.4 and not in_untouch:
			if rng.randf() < 0.4:
				x.rotation_idx = Utils.get_random(rng, rotates)
				x.scene_idx = Utils.get_random(rng, trees)
				blocked.append(x.id)
				
		elif value > 0.2 and value < 0.3:
			x.scene_idx = TileIndex.tile_names[TileIndex.mud]
		elif value > 0.1 and value < 0.2:
			x.scene_idx = TileIndex.tile_names[TileIndex.sand]
		elif value < 0.1 and not in_untouch:
			x.scene_idx = TileIndex.tile_names[TileIndex.water]
			blocked.append(x.id)
			
	for i in map_data.navigations[0]:
		i.enable = not (i.id in blocked)
		
func display_selected_nav(layer_id :int):
	nav_tiles.clear()
	
	var items = []
	for i in highlights.get_children():
		highlights.remove_child(i)
		items.append(i)
		
	batch_despawner.start(items, 16)
	batch_spawner.start(Global.current_tile_map_file_data.navigations[layer_id], 16)
	
func display_untouch_tile():
	for i in spawn_tiles:
		i.queue_free()
		
	spawn_tiles.clear()
	
	for tile in untouch_tiles:
		var h = preload("res://assets/tile_highlight/spawn_tile.tscn").instance()
		add_child(h)
		h.translation = nav.get_pos_v3(tile) * 1.02
		spawn_tiles.append(h)
	
func _on_batch_spawner_on_spawn(n :NavigationData):
	var h = preload("res://assets/tile_highlight/tile_highlight.tscn").instance()
	highlights.add_child(h)
	h.set_text("%s\n%s" % [n.id, n.navigation_id])
	h.enable(n.enable)
	h.translation = n.pos * 1.02
	nav_tiles[n.id] = h
	
func _on_random_button_press():
	randomize_map_data(untouch_tiles)
	editable_tile_map.load_data_map(Global.current_tile_map_file_data, true)
	ui.minimap.load_data_map(Global.current_tile_map_file_data)
	ui.loading_screen.visible = true
	
func _on_nav_toggle_button_press():
	highlights.visible = not highlights.visible
	ui.on_nav_toggle_pressed()
	
func _on_editable_tile_map_on_map_ready():
	nav = editable_tile_map.get_nav_tile_map()
	display_selected_nav(0)
	display_untouch_tile()
	ui.on_map_ready()
	
func _on_clickable_floor_on_floor_clicked(pos):
	var tile :TileMapData = editable_tile_map.get_closes_tile(pos)
	
func _on_ui_on_tile_card_dropped(posv2 :Vector2, tile_data :TileMapData):
	var posv3 = Utils.screen_to_world(get_viewport().get_camera(), posv2, false, 4)
	
	var tile :TileMapData = editable_tile_map.get_closes_tile(posv3)
	if tile.id in untouch_tiles and not tile_data.scene_idx in [0,1,2,3]:
		return
	
	tile_data.id = tile.id
	tile_data.pos = tile.pos
	
	editable_tile_map.update_spawned_tile(tile_data)
	
func _on_editable_tile_map_on_tile_updated(id, data, node):
	var enable_nav = data.scene_idx in [0,1,2,3]
	ui.minimap.update_spawned_tile(data)
	nav.enable_nav_tile(0, id, enable_nav)
	nav_tiles[id].enable(enable_nav)
	
func _on_ui_on_nav_card_dropped(posv2, enable):
	var posv3 = Utils.screen_to_world(get_viewport().get_camera(), posv2, false, 4)
	var tile :TileMapData = editable_tile_map.get_closes_tile(posv3)
	if tile.id in untouch_tiles:
		return
		
	nav.enable_nav_tile(0, tile.id, enable)
	nav_tiles[tile.id].enable(enable)

func _on_biom_button_press(idx):
	editable_tile_map.biom = idx
	editable_tile_map.load_data_map(Global.current_tile_map_file_data, true)
	
	ui.minimap.biom = idx
	ui.minimap.load_data_map(Global.current_tile_map_file_data)
	ui.loading_screen.visible = true
	
	for i in ui.biom_buttons.size():
		ui.biom_buttons[i].disabled = false
		
	ui.option_biom.visible = false
	ui.biom_buttons[idx].disabled = true



















