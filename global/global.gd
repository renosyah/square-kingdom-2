extends Node

func _ready():
	SaveLoad.ensure_dir("user://%s/" % map_dir)
	
	init_save_load_map()
	setup_transition()
	load_player_data()
	setup_tick()
	load_custom_squad()
	setup_music()
	load_Setting()
	
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

var player_materials = [] # SpatialMaterial

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
		player_data.color_idx = randi() % EntityIndex.player_colors.size()  # exlude last
		player_data.potrait_idx = randi() % EntityIndex.player_potraits.size()
		save_player_data()
		
	else:
		player_data.from_dictionary(data)
		
	
	for i in EntityIndex.player_colors:
		var material = SpatialMaterial.new()
		material.albedo_color = i
		player_materials.append(material)
		
func save_player_data():
	SaveLoad.save(player_data_filepath, player_data.to_dictionary(), true)
	
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
	current_tile_map_manifest_data.map_size = 18
	
	current_tile_map_file_data = TileMapUtils.generate_empty_tile_map(
		current_tile_map_manifest_data.map_size, 1
	)
	
func null_map_data():
	current_tile_map_manifest_data = null
	current_tile_map_file_data = null
	
func set_active_map(manif :TileMapFileManifest):
	current_tile_map_manifest_data = manif
	
	save_load_map.load_data_async(manif.map_file_path,false)
	var results = yield(save_load_map,"load_done")
	current_tile_map_file_data = TileMapFileData.new()
	current_tile_map_file_data.from_dictionary(results[1])
	
func save_edited_map(vp :Viewport):
	var map_file = yield(_save_map(),"completed")
	yield(_save_manifest(map_file,vp),"completed")
	
func _save_map() -> String:
	var map_name = current_tile_map_manifest_data.map_name
	var file_path = "user://%s/%s.map" % [map_dir, map_name]
	save_map(file_path, current_tile_map_file_data.to_dictionary(), false)
	yield(save_load_map,"save_done")
	return file_path
	
func _save_manifest(map_file:String,vp :Viewport):
	var map_name = current_tile_map_manifest_data.map_name
	var file_path = "user://%s/%s.manifest" % [map_dir, map_name]
	var img_path = yield(save_ss(map_name,vp), "completed")
	current_tile_map_manifest_data.map_image_file_path = img_path
	current_tile_map_manifest_data.map_file_path = map_file
	
	# uses save load, cause data not that many LOL
	SaveLoad.save(file_path, current_tile_map_manifest_data.to_dictionary(), false)
	
func delete_map():
	var map_name = current_tile_map_manifest_data.map_name
	SaveLoad.delete_save("user://%s/%s.manifest" % [map_dir, map_name], false)
	SaveLoad.delete_save("user://%s/%s.map" % [map_dir, map_name], false)
	
func save_ss(map_name:String, vp :Viewport) -> String:
	var img: Image = vp.get_texture().get_data()
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
	
##########################################  music  ############################################
const main_music = "res://music/medieval_theme.ogg"

var music :AudioStreamPlayer
const bus_music = "music"
const bus_sfx = "sfx"
const bus_voice = "voice"

func setup_music():
	music = AudioStreamPlayer.new()
	music.bus = bus_music
	music.volume_db = -8.0
	
	if ResourceLoader.exists(main_music):
		music.stream = preload(main_music)
		
	music.autoplay = true
	add_child(music)
	
func set_bus_volume(bus_name :String, volume :float, mute :bool = false):
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, linear2db(volume)) 
	
func set_bus_mute(bus_name :String, v :bool):
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_mute(bus_index, v)
	
##########################################  setting  ############################################
signal on_setting_updated(data)

const setting_filepath :String = "setting.dat"
var setting_data :SettingData

func load_Setting():
	setting_data = SettingData.new()
	var data = SaveLoad.load_save(setting_filepath, true)
	if data == null:
		setting_data = SettingData.new()
		save_setting()
		
	else:
		setting_data.from_dictionary(data)
		
	# apply audio setting
	var audios = {
		bus_music:setting_data.music,
		bus_sfx:setting_data.sfx,
		bus_voice:setting_data.voice
	}
	for key in audios.keys():
		set_bus_volume(key, audios[key])
		set_bus_mute(key, setting_data.mute)
		
func setting_updated():
	emit_signal("on_setting_updated", setting_data)

func save_setting():
	SaveLoad.save(setting_filepath, setting_data.to_dictionary(), true)

##########################################  transisiion  ############################################
var transition :CanvasLayer

func setup_transition():
	transition = preload("res://assets/transision_screen/transision_screen.tscn").instance()
	add_child(transition)
	
func change_scene(scene :String, use :bool = false, bg_idx :int = 0):
	transition.change_scene(scene, use, bg_idx)
	
func hide_transition():
	transition.hide_transition()
	
##########################################  army editor  ############################################
const custom_squads_filepath :String = "custom_squads.dat"

const template_squads = [
	preload("res://data/squad_data/peasant.tres"),#0
	preload("res://data/squad_data/axeman.tres"),
	preload("res://data/squad_data/javeliner.tres"),
	preload("res://data/squad_data/spearman.tres"),
	preload("res://data/squad_data/swordman.tres"),
	preload("res://data/squad_data/archer.tres"),#5
	preload("res://data/squad_data/pikeman.tres"),
	preload("res://data/squad_data/knight.tres"),
	preload("res://data/squad_data/crossbowman.tres"),
	preload("res://data/squad_data/elite_guard.tres"),
	preload("res://data/squad_data/huscarls.tres"), #10
	preload("res://data/squad_data/longbowman.tres"),
	preload("res://data/squad_data/cavalry_spear.tres"),
	preload("res://data/squad_data/cavalry_sword.tres"),
	preload("res://data/squad_data/cavalry_archer.tres"),
	preload("res://data/squad_data/cavalry_lancer.tres"),#15
	preload("res://data/squad_data/cavalry_paladin.tres"),
	preload("res://data/squad_data/cavalry_household.tres"),
	preload("res://data/squad_data/engine_catapult.tres"),
	preload("res://data/squad_data/engine_balista.tres"),
	preload("res://data/squad_data/engine_trebuchet.tres")
]
onready var custom_squads :Array = []

func set_default_squad_army():
	for i in template_squads:
		custom_squads.append(i.duplicate())
		
	current_army = [3,3,4,4,5,5,8,12]
	sort_army(current_army)
	
func load_custom_squad():
	var data = SaveLoad.load_save(custom_squads_filepath, true)
	if data == null:
		set_default_squad_army()
		save_custom_squad()
		return
		
	custom_squads = []
	for i in data["s"]:
		var s :SquadData = SquadData.new()
		s.from_dictionary(i)
		custom_squads.append(s)
		
	current_army = data["a"]
	
func save_custom_squad():
	var datas = []
	for i in custom_squads:
		var s :SquadData = i
		datas.append(s.to_dictionary())
		
	var data :Dictionary = {"s":datas,"a":current_army}
	SaveLoad.save(custom_squads_filepath, data, true)
	
##########################################  lobby & gameplay  ############################################
var current_root :Node
var scores :Dictionary = {}
var is_win :bool

var current_player :PlayerData # specific for game session
var players :Array = [] # list of players in MP

# value of index of custom_squads
# so if anything in custom_squads update
# current_army will also updated too
var current_army :Array = []
var max_army_size :int = 9

var bot_players :Array = []
var bot_player_armies :Dictionary = {} # {player_id:[int]}

func prepare_army(army :Array, spawn_pos :Vector2, player :PlayerData) -> Array:
	var datas = []
	var tiles = [spawn_pos] + TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(), spawn_pos, 1
	)
	for idx in army.size():
		var tile_id = tiles[idx]
		var squad :SquadData = prepare_squad(idx, army[idx], player, tile_id)
		datas.append(squad)
		
	return datas
	
func sort_army(datas :Array):
	datas.sort_custom(self, "_sort_by_order")
	
func _sort_by_order(a, b):
	return custom_squads[a].sort_order < custom_squads[b].sort_order

# idx is from current_army
func prepare_squad(i :int, idx :int, player :PlayerData, tile_id :Vector2) -> SquadData:
	var data :SquadData = custom_squads[idx].duplicate()
	data.network_id = player.player_network_id
	data.player_id = player.player_id
	data.node_name = "squad_%s_%s" % [player.player_id, Utils.create_unique_id()]
	data.current_tile = tile_id
	data.color_idx = player.color_idx
	data.team = player.team
	
	# 1st position is commander
	# twice HP
	if i == 0:
		data.icon_idx = 6
		data.member_hp = data.member_hp * 2
		data.spawn_time = 5
		
	return data

func create_bot_player() -> Array:
	var p = PlayerData.new()
	p.player_network_id = 1
	p.player_id = "bot_%s" % Utils.create_unique_id()
	p.player_name = "%s (bot)" % RandomNameGenerator.generate_name()
	p.team = bot_players.size() + players.size() + 1
	p.color_idx = randi() % EntityIndex.player_colors.size() - 1 # exlude last
	p.potrait_idx = randi() % EntityIndex.player_potraits.size()

	var _bot_player_armies = []
	var count = int(rand_range(3, 9))
		
	for i in count:
		var idx = randi() % custom_squads.size()
		if _bot_player_armies.size() < max_army_size:
			_bot_player_armies.append(idx)
			
	sort_army(_bot_player_armies)
	return [p, _bot_player_armies]

















