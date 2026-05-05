extends Node

func _ready():
	SaveLoad.ensure_dir("user://%s/" % map_dir)
	
	init_save_load_map()
	setup_transition()
	load_player_data()
	setup_tick()
	
##########################################  tick  ############################################

signal on_global_tick

var _tick :Timer

func setup_tick():
	_tick = Timer.new()
	_tick.wait_time = 1
	_tick.one_shot = true
	_tick.connect("timeout", self, "_on_tick")
	add_child(_tick)
	_tick.start()
	
func _on_tick():
	emit_signal("on_global_tick")
	_tick.start()
	
##########################################  player data  ############################################

const player_data_filepath :String = "player_data.dat"
var player_data :PlayerData

func monitor_network():
	Network.connect("server_player_connected", self, "_on_player_connected")
	Network.connect("client_player_connected", self, "_on_player_connected")
	
func _on_player_connected(player_network_unique_id :int):
	player_data.player_network_id = player_network_unique_id

func load_player_data():

	player_data = PlayerData.new()
	var data = SaveLoad.load_save(player_data_filepath, true)
	if data == null:
		player_data.player_id = Utils.create_unique_id()
		player_data.player_name = OS.get_name()
		player_data.team = 1
		SaveLoad.save(player_data_filepath, player_data.to_dictionary(), true)
		
	else:
		player_data.from_dictionary(data)
		
##########################################  maps  ############################################
# for load and save maps
const map_dir = "map"
var save_load_map :SaveLoadImproved

onready var current_tile_map_manifest_datas :Array = [] # [ TileMapFileManifest ]

func init_save_load_map():
	save_load_map = preload("res://addons/save_load/save_load_improve.tscn").instance()
	add_child(save_load_map)
	
func load_maps() :
	current_tile_map_manifest_datas.clear()
	var list :PoolStringArray = Utils.get_all_resources("user://%s/" % map_dir, ["manifest"])
	for i in list:
		var m :TileMapFileManifest = TileMapFileManifest.new()
		var data = SaveLoad.load_save(i,false)
		m.from_dictionary(data)
		current_tile_map_manifest_datas.append(m)
		
func save_map(filename :String, data, use_prefix = true):
	var path = "%s/%s" %[map_dir, filename] if use_prefix else filename
	save_load_map.save_data_async(path, data, use_prefix)
	
##########################################  selected map  ############################################

var current_tile_map_manifest_data :TileMapFileManifest
var current_tile_map_file_data :TileMapFileData

func empty_map_data():
	current_tile_map_manifest_data = TileMapFileManifest.new()
	current_tile_map_manifest_data.map_name = RandomNameGenerator.generate_name()
	current_tile_map_manifest_data.map_size = 8
	
	current_tile_map_file_data = TileMapUtils.generate_empty_tile_map(current_tile_map_manifest_data.map_size)
	
func null_map_data():
	current_tile_map_manifest_data = null
	current_tile_map_file_data = null
	
func save_edited_map():
	var map_file = yield(_save_map(),"completed")
	yield(_save_manifest(map_file),"completed")
	
func _save_map() -> String:
	var map_name = current_tile_map_manifest_data.map_name
	var file_path = "user://%s/%s.map" % [map_dir, map_name]
	save_map(file_path, current_tile_map_file_data.to_dictionary(), false)
	yield(save_load_map,"save_done")
	return file_path
	
func _save_manifest(map_file:String):
	var map_name = current_tile_map_manifest_data.map_name
	var file_path = "user://%s/%s.manifest" % [map_dir, map_name]
	var img_path = yield(save_ss(map_name), "completed")
	current_tile_map_manifest_data.map_image_file_path = img_path
	current_tile_map_manifest_data.map_file_path = map_file
	
	# uses save load, cause data not that many LOL
	SaveLoad.save(file_path, current_tile_map_manifest_data.to_dictionary(), false)
	
func save_ss(map_name:String) -> String:
	var img: Image = get_viewport().get_texture().get_data()
	img.flip_y()
	
	var w = img.get_width()
	var h = img.get_height()
	var crop_rect = Rect2((w - 512)/2, (h - 512)/2, 512, 512)
	var img_path = "user://%s/%s.png" % [map_dir, map_name]
	var cropped_img = Image.new()
	cropped_img.create(512, 512, false, img.get_format())
	cropped_img.blit_rect(img, crop_rect, Vector2(0,0))
	cropped_img.save_png(img_path)
	yield(get_tree(),"idle_frame")
	
	return img_path
	
	
##########################################  transisiion  ############################################
var transition :CanvasLayer

func setup_transition():
	transition = preload("res://assets/transision_screen/transision_screen.tscn").instance()
	add_child(transition)
	
func change_scene(scene :String, use :bool = false, bg_idx :int = 0):
	transition.change_scene(scene, use, bg_idx)
	
func hide_transition():
	transition.hide_transition()
