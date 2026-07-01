extends Node

const is_dekstop =  ["Server", "Windows", "WinRT", "X11"]

func _ready():
	randomize()
	
	SaveLoad.ensure_dir("user://%s/" % map_dir)
	
	init_save_load_map()
	setup_transition()
	load_player_data()
	setup_tick()
	load_squads()
	load_army()
	set_default_squad_army()
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
		player_data.potrait_idx = randi() % EntityIndex.squad_potraits.size()
		save_player_data()
		
	else:
		player_data.from_dictionary(data)
		
	
	for i in EntityIndex.player_colors:
		var material = SpatialMaterial.new()
		material.flags_vertex_lighting = true
		material.vertex_color_use_as_albedo = true
		material.albedo_color = i
		material.flags_do_not_receive_shadows = true
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

func empty_map_data(map_name :String, map_size :int):
	current_tile_map_manifest_data = TileMapFileManifest.new()
	current_tile_map_manifest_data.map_name = map_name
	current_tile_map_manifest_data.map_size = map_size
	
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
	transition = preload("res://assets/user_interface/transision_screen/transision_screen.tscn").instance()
	add_child(transition)
	
func change_scene(scene :String, use :bool = false, bg_idx :int = 0):
	transition.change_scene(scene, use, bg_idx)
	
func hide_transition():
	transition.hide_transition()
	
##########################################  army editor  ############################################
const default_squads_filepath :String = "custom_squads.dat"
const default_army_filepath :String = "custom_army.dat"

const template_squads = [
	preload("res://data/squad_data/peasant.tres"),#0
	preload("res://data/squad_data/axeman.tres"),
	preload("res://data/squad_data/javeliner.tres"),
	preload("res://data/squad_data/spearman.tres"),
	preload("res://data/squad_data/swordman.tres"),
	preload("res://data/squad_data/archer.tres"),#5
	preload("res://data/squad_data/arabian_spearman.tres"),
	preload("res://data/squad_data/arabian_swordman.tres"),
	preload("res://data/squad_data/arabian_archer.tres"),
	preload("res://data/squad_data/pikeman.tres"),
	preload("res://data/squad_data/knight.tres"), # 10
	preload("res://data/squad_data/crossbowman.tres"),
	preload("res://data/squad_data/elite_guard.tres"),
	preload("res://data/squad_data/huscarls.tres"),
	preload("res://data/squad_data/longbowman.tres"),
	preload("res://data/squad_data/cavalry_spear.tres"), #15
	preload("res://data/squad_data/cavalry_sword.tres"),
	preload("res://data/squad_data/cavalry_archer.tres"),
	preload("res://data/squad_data/cavalry_lancer.tres"),
	preload("res://data/squad_data/cavalry_paladin.tres"),
	preload("res://data/squad_data/cavalry_household.tres"), # 20
	preload("res://data/squad_data/engine_catapult.tres"),
	preload("res://data/squad_data/engine_balista.tres"),
	preload("res://data/squad_data/engine_trebuchet.tres")
]
# why current_army is array of int
# its a value of index of custom_squads
# so if anything in custom_squads update
# current_army will also updated too
var current_player :PlayerData # specific for game session
var current_squads :Array = [] # [SquadData] copied
var current_army :Array = [] # [int]
var current_army_cards :Array = [] #[ArmyCardData]

# run once
func set_default_squad_army():
	for i in 4:
		var c = ArmyCardData.new()
		c.generate_card([], randf() < 0.5)
		current_army_cards.append(c)
	
	if not current_squads.empty(): # chech
		return
		
	for i in template_squads:
		current_squads.append(i.duplicate())
		
	current_army = [3,3,4,4,5,5,11,15]
	sort_army(current_army)
	
	save_squads()
	save_army()
	
func load_squads(filepath :String = default_squads_filepath):
	current_squads = []
	var data = SaveLoad.load_save(filepath, true)
	if data != null:
		for i in data["s"]:
			var s :SquadData = SquadData.new()
			s.from_dictionary(i)
			current_squads.append(s)
	
func save_squads(filepath :String = default_squads_filepath):
	var datas = []
	for i in current_squads:
		var s :SquadData = i
		datas.append(s.to_dictionary())
		
	var data :Dictionary = {"s":datas}
	SaveLoad.save(filepath, data, true)
	
func load_army(filepath :String = default_army_filepath):
	current_army = []
	var data = SaveLoad.load_save(filepath, true)
	if data != null:
		current_army = data["a"]
		
func save_army(filepath :String = default_army_filepath):
	var data :Dictionary = {"a":current_army}
	SaveLoad.save(filepath, data, true)
	
##########################################  lobby & gameplay  ############################################
const max_army_size :int = 9

# players
var players :Array = [] # list of players in MP
var bot_players :Array = [] # list of bot players in MP
var bot_player_armies :Dictionary = {} # {bot_player_id:[int]}

# battle setting
var current_root :Node
var battle_time :int
var scores :Dictionary = {}
var is_win :bool
var player_map_data_received :Array = []

var enable_fort :bool = true # just for MP BATTLE
var enable_bandit :bool = true
var biom :int

# position:[
#	enable fort, 
#	spawn size: 2 & 3, 
#	type: 0=camp,1=village,2=city,
#	gate_stat: 0=none,1:closed,2:open,3:destroyed
#]
var spawn_point_forts :Dictionary = {
	0:[true, 2, 0, 1], # TOP
	1:[true, 2, 0, 1], # LEFT
	2:[true, 2, 0, 1], # RIGHT
	3:[true, 2, 0, 1], # DOWN
	4:[true, 2, 0, 0], # center of map
}

func get_total_cards_extra_bonuses(cards :Array) -> ArmyCardData:
	var c = ArmyCardData.new()
	for i in cards:
		var _c :ArmyCardData = i
		c.sum(_c.get_extra())
		
	return c

func prepare_army(army :Array, spawn_pos :Vector2, player :PlayerData, sum_card :ArmyCardData = null) -> Array:
	var datas = []
	
	var extra = {}
	if sum_card != null:
		extra = sum_card.get_extra()
		
	var tiles = [spawn_pos] + TileMapUtils.get_adjacent_tiles(
		TileMapUtils.ARROW_DIRECTIONS, spawn_pos, 1
	)
	var tile_idx = 0
	for idx in army.size():
		if tile_idx > tiles.size() - 1:
			tile_idx = 0
		
		var tile_id = tiles[tile_idx]
		var squad :SquadData = prepare_squad(idx, army[idx], player, tile_id, extra)
		datas.append(squad)
		
		tile_idx += 1
		
	return datas
	
func sort_army(datas :Array):
	datas.sort_custom(self, "_sort_by_order")
	
func _sort_by_order(a, b):
	return current_squads[a].sort_order < current_squads[b].sort_order

# idx is from current_army
func prepare_squad(i :int, squad_idx :int, player :PlayerData, tile_id :Vector2, extra :Dictionary) -> SquadData:
	var data :SquadData = current_squads[squad_idx].duplicate()
	data.extra = extra
	data.squad_id = i
	data.sort_order = i
	data.network_id = player.player_network_id
	data.player_id = player.player_id
	data.node_name = "squad_%s_%s" % [player.player_id, Utils.create_unique_id()]
	data.current_tile = tile_id
	data.color_idx = player.color_idx
	data.team = player.team
	
	# 1st position is commander
	if i == 0:
		data.icon_idx = 6
		data.is_commander = true
		
		# if no ability set
		# the special for commander will be set instead
		if data.squad_ability_idx == 0:
			data.squad_ability_idx = 18
		
	return data

func create_bot_player() -> Array:
	var p = PlayerData.new()
	p.player_network_id = 1
	p.player_id = "bot_%s" % Utils.create_unique_id()
	p.player_name = "%s (bot)" % RandomNameGenerator.generate_name()
	p.team = bot_players.size() + players.size() + 1
	p.color_idx = randi() % (EntityIndex.player_colors.size() - 1) # exlude last
	p.potrait_idx = randi() % EntityIndex.squad_potraits.size()
	p.spawn_position = bot_players.size() + players.size()
	
	var _bot_player_armies = []
	var count = int(rand_range(5, 9))
	
	for i in count:
		var idx = randi() % current_squads.size()
		_bot_player_armies.append(idx)
		
	sort_army(_bot_player_armies)
	return [p, _bot_player_armies]

















