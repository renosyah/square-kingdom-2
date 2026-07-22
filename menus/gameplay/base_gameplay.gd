extends Node
class_name BaseGameplay

onready var is_server = NetworkLobbyManager.is_server()

func _ready():
	Global.current_root = self
	
	self.name = "gameplay"
	
	Global.connect("on_setting_updated", self, "_on_setting_updated")
	
	NetworkLobbyManager.connect("all_player_ready", self, "_on_all_player_ready")
	NetworkLobbyManager.connect("on_host_disconnected", self, "_on_leave")
	NetworkLobbyManager.connect("on_leave", self, "_on_leave")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	setup_bandit_mob()
	setup_ambient_audio()
	setup_unit_position_manager()
	spawn_tile_map()
	spawn_movable_camera()
	spawn_enviroment()
	setup_clickable_floor()
	setup_ui()
	set_tap()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			#on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			#on_back_pressed()
			return
			
func on_back_pressed():
	NetworkLobbyManager.leave()
	
func _on_leave():
	Global.current_root = null
	Global.change_scene("res://menus/main_menu/main_menu.tscn", true)
	
func _on_all_player_ready():
	if is_server:
		spawn_squads(tower_datas)
		rpc("_spawn_camps", camp_buildings)
		
	Global.battle_time = 0
	Global.hide_transition()
	Global.connect("on_global_tick", self, "_on_global_tick")
	start_spawn_army()
	
func _on_global_tick():
	if not is_end:
		Global.battle_time += 1
	
########################################## proccess  ############################################

func _process(delta):
	if ui.on_cinematic_mode:
		movable_camera.translation = orbital_camera.translation
	
	var pos = movable_camera.translation * Vector3(1,0,1)
	tile_map.update_camera_location(Vector2(pos.x, pos.z))
	
	if is_instance_valid(ui):
		if ui.cam_rot_l.pressed:
			movable_camera.rotation_degrees.y -= setting.camera_rotation_speed * delta
		elif ui.cam_rot_r.pressed:
			movable_camera.rotation_degrees.y += setting.camera_rotation_speed * delta
			
		clickable_floor.translation = pos
		ui.minimap.rotation_rad = movable_camera.rotation.y
		ui.minimap.offset = Vector2(pos.x, pos.z) * 10
		
########################################## ambient sound  ############################################

# memes
const memes = [
	preload("res://assets/sounds/memes/19_juta.wav"),#0
	preload("res://assets/sounds/memes/hidup_jokowi.wav"),#1
	preload("res://assets/sounds/memes/saya_akan_lawan.wav"),#2
	preload("res://assets/sounds/memes/akan_saya_lawan_2.wav"),#3
	preload("res://assets/sounds/memes/antek_asing.wav"),
	preload("res://assets/sounds/memes/lho_kaget.wav"),
	preload("res://assets/sounds/memes/jkw_pidato_jogja_1.wav"),
	preload("res://assets/sounds/memes/jkw_pidato_jogja_2.wav"),
	preload("res://assets/sounds/memes/jkw_pidato_jogja_3.wav"),
	preload("res://assets/sounds/memes/bekerja_mati_matian.wav"),
	preload("res://assets/sounds/memes/wewokdetok.wav"),
	preload("res://assets/sounds/memes/saya_masih_sangup_1.wav"),
	preload("res://assets/sounds/memes/saya_masih_sangup_2.wav")
]
const memes2 = [
	preload("res://assets/sounds/memes/akh.wav"),
	preload("res://assets/sounds/memes/boom.wav"),
	preload("res://assets/sounds/memes/faa.wav"),
	preload("res://assets/sounds/memes/ayam_teriak.wav"),
	preload("res://assets/sounds/memes/bruh.wav"),
	preload("res://assets/sounds/memes/cat_laught.wav"),
]
const saya_akan_kembali = preload("res://assets/sounds/memes/saya_akan_kembali.wav")

const regroup = preload("res://assets/sounds/gameplay/regroup.wav")
const attack_sfx = preload("res://assets/sounds/gameplay/attack.wav")
const buff = preload("res://assets/sounds/gameplay/buff.wav")
const debuff = preload("res://assets/sounds/gameplay/debuff.wav")

const attack = [
	preload("res://assets/sounds/unit/attack/attack_1_1.wav"), preload("res://assets/sounds/unit/attack/attack_1_2.wav"), preload("res://assets/sounds/unit/attack/attack_1_3.wav"), preload("res://assets/sounds/unit/attack/attack_1_4.wav")
]
const movement = [
	preload("res://assets/sounds/unit/move/moving_1_1.wav"), preload("res://assets/sounds/unit/move/moving_1_2.wav"), preload("res://assets/sounds/unit/move/moving_1_3.wav"), preload("res://assets/sounds/unit/move/moving_1_4.wav"), preload("res://assets/sounds/unit/move/moving_2_1.wav"), preload("res://assets/sounds/unit/move/moving_2_2.wav"), preload("res://assets/sounds/unit/move/moving_2_3.wav")
]
const selection = [
	preload("res://assets/sounds/unit/selection/selection_1_1.wav"), preload("res://assets/sounds/unit/selection/selection_1_2.wav"), preload("res://assets/sounds/unit/selection/selection_1_3.wav"), preload("res://assets/sounds/unit/selection/selection_2_1.wav"), preload("res://assets/sounds/unit/selection/selection_2_2.wav"), preload("res://assets/sounds/unit/selection/selection_2_3.wav"), preload("res://assets/sounds/unit/selection/selection_3_1.wav"), preload("res://assets/sounds/unit/selection/selection_3_2.wav"), preload("res://assets/sounds/unit/selection/selection_3_3.wav"), preload("res://assets/sounds/unit/selection/selection_3_4.wav")
]
const cav_charged = [
	preload("res://assets/sounds/unit/charge_impact/cav_charge_ok_1.wav"), preload("res://assets/sounds/unit/charge_impact/cav_charge_ok_2.wav"), preload("res://assets/sounds/unit/charge_impact/cav_charge_ok_3.wav"), preload("res://assets/sounds/unit/charge_impact/cav_charge_ok_4.wav")
]

const selection_group = [
	[],
	[preload("res://assets/sounds/gameplay/mounted_group_select_1.wav"), preload("res://assets/sounds/gameplay/mounted_group_select_2.wav"), preload("res://assets/sounds/gameplay/mounted_group_select_3.wav"), preload("res://assets/sounds/gameplay/mounted_group_select_4.wav"), preload("res://assets/sounds/gameplay/mounted_group_select_5.wav"), preload("res://assets/sounds/gameplay/mounted_group_select_6.wav")],
	[preload("res://assets/sounds/gameplay/infantry_group_select_1.wav"), preload("res://assets/sounds/gameplay/infantry_group_select_2.wav"), preload("res://assets/sounds/gameplay/infantry_group_select_3.wav"), preload("res://assets/sounds/gameplay/infantry_group_select_4.wav"), preload("res://assets/sounds/gameplay/infantry_group_select_5.wav")],
	[preload("res://assets/sounds/gameplay/missile_group_select_1.wav"), preload("res://assets/sounds/gameplay/missile_group_select_2.wav"), preload("res://assets/sounds/gameplay/missile_group_select_3.wav")],
]

const announce_squad_killed = [
	preload("res://assets/sounds/announcement/squad_kill_1.wav"), preload("res://assets/sounds/announcement/squad_kill_2.wav"), preload("res://assets/sounds/announcement/squad_kill_3.wav"), preload("res://assets/sounds/announcement/squad_kill_4.wav"), preload("res://assets/sounds/announcement/squad_kill_5.wav"), preload("res://assets/sounds/announcement/squad_kill_6.wav")
]
const announce_squad_lost = [
	preload("res://assets/sounds/announcement/squad_lost_1.wav"), preload("res://assets/sounds/announcement/squad_lost_2.wav"), preload("res://assets/sounds/announcement/squad_lost_3.wav"), preload("res://assets/sounds/announcement/squad_lost_4.wav"), preload("res://assets/sounds/announcement/squad_lost_5.wav"), preload("res://assets/sounds/announcement/squad_lost_6.wav")
]
const announce_guard_lost = [
	preload("res://assets/sounds/announcement/guard_lost_1.wav"), preload("res://assets/sounds/announcement/guard_lost_2.wav"), preload("res://assets/sounds/announcement/guard_lost_3.wav"), preload("res://assets/sounds/announcement/guard_lost_4.wav"), preload("res://assets/sounds/announcement/guard_lost_5.wav"),preload("res://assets/sounds/announcement/guard_lost_4.wav"),
]
const announce_commander_killed = [
	preload("res://assets/sounds/announcement/commander_kill_1.wav"), preload("res://assets/sounds/announcement/commander_kill_2.wav"), preload("res://assets/sounds/announcement/commander_kill_3.wav"), preload("res://assets/sounds/announcement/commander_kill_4.wav"), preload("res://assets/sounds/announcement/commander_kill_5.wav"), preload("res://assets/sounds/announcement/commander_kill_6.wav")
]
const announce_commander_lost = [
	preload("res://assets/sounds/announcement/commander_lost_1.wav"), preload("res://assets/sounds/announcement/commander_lost_2.wav"), preload("res://assets/sounds/announcement/commander_lost_3.wav"), preload("res://assets/sounds/announcement/commander_lost_4.wav"), preload("res://assets/sounds/announcement/commander_lost_5.wav"), preload("res://assets/sounds/announcement/commander_lost_6.wav")
]
const announce_hero_killed = [
	preload("res://assets/sounds/announcement/hero_kill_1.wav"), preload("res://assets/sounds/announcement/hero_kill_2.wav"), preload("res://assets/sounds/announcement/hero_kill_3.wav"), preload("res://assets/sounds/announcement/hero_kill_4.wav"), preload("res://assets/sounds/announcement/hero_kill_5.wav"),preload("res://assets/sounds/announcement/hero_kill_1.wav"),
]
const announce_hero_lost = [
	preload("res://assets/sounds/announcement/hero_lost_1.wav"), preload("res://assets/sounds/announcement/hero_lost_2.wav"), preload("res://assets/sounds/announcement/hero_lost_3.wav"), preload("res://assets/sounds/announcement/hero_lost_4.wav"), preload("res://assets/sounds/announcement/hero_lost_5.wav"),preload("res://assets/sounds/announcement/hero_lost_3.wav"),
]
const announce_squad_spawned = [
	preload("res://assets/sounds/announcement/reinforcement_1.wav"), preload("res://assets/sounds/announcement/reinforcement_2.wav"), preload("res://assets/sounds/announcement/reinforcement_3.wav"), preload("res://assets/sounds/announcement/reinforcement_4.wav"), preload("res://assets/sounds/announcement/reinforcement_5.wav"), preload("res://assets/sounds/announcement/reinforcement_6.wav")
]
const announce_commander_spawned = [
	preload("res://assets/sounds/announcement/commander_arrive _1.wav"), preload("res://assets/sounds/announcement/commander_arrive _2.wav"), preload("res://assets/sounds/announcement/commander_arrive _3.wav"), preload("res://assets/sounds/announcement/commander_arrive _4.wav"), preload("res://assets/sounds/announcement/commander_arrive _5.wav"), preload("res://assets/sounds/announcement/commander_arrive _6.wav")
]
const announce_hero_spawned = [
	preload("res://assets/sounds/announcement/hero_arrive_1.wav"), preload("res://assets/sounds/announcement/hero_arrive_2.wav"), preload("res://assets/sounds/announcement/hero_arrive_3.wav"), preload("res://assets/sounds/announcement/hero_arrive_4.wav"), preload("res://assets/sounds/announcement/hero_arrive_5.wav"),preload("res://assets/sounds/announcement/hero_arrive_2.wav")
]

var ui_sound :AudioStreamPlayer
var unit_sound :AudioStreamPlayer
var annoucer_sound :AudioStreamPlayer

func setup_ambient_audio():
	ui_sound = AudioStreamPlayer.new()
	ui_sound.volume_db = -8.0
	ui_sound.bus = Global.bus_sfx
	add_child(ui_sound)
	
	unit_sound = AudioStreamPlayer.new()
	unit_sound.bus = Global.bus_voice
	unit_sound.volume_db = -4
	add_child(unit_sound)
	
	annoucer_sound = AudioStreamPlayer.new()
	annoucer_sound.bus = Global.bus_voice
	annoucer_sound.volume_db = 6
	add_child(annoucer_sound)
	
func unit_move_response(w :bool = false):
	if annoucer_sound.playing:
		return
		
	if unit_sound.playing and w:
		return
		
	unit_sound.stream = movement.pick_random()
	unit_sound.play()
	
func unit_select_response(w :bool = false):
	if annoucer_sound.playing:
		return
		
	if unit_sound.playing and w:
		return
		
	unit_sound.stream = selection.pick_random()
	unit_sound.play()
	
func unit_attacking_response(w :bool = false):
	if annoucer_sound.playing:
		return
		
	if unit_sound.playing and w:
		return
		
	unit_sound.stream = attack.pick_random()
	unit_sound.play()
	
func unit_charged_impact(w :bool = false):
	if annoucer_sound.playing:
		return
		
	if unit_sound.playing and w:
		return
		
	unit_sound.stream = cav_charged.pick_random()
	unit_sound.play()
	
func play_squad_lost(is_commander :bool, is_hero :bool, is_guard :bool):
	if annoucer_sound.playing:
		return
		
	if (is_commander and is_hero) or is_commander:
		annoucer_sound.stream = announce_commander_lost.pick_random()
	elif is_hero:
		annoucer_sound.stream = announce_hero_lost.pick_random()
	elif is_guard:
		annoucer_sound.stream = announce_guard_lost.pick_random()
	else:
		annoucer_sound.stream = announce_squad_lost.pick_random()
		
	annoucer_sound.play()

func play_squad_killed(is_commander :bool, is_hero :bool):
	if annoucer_sound.playing:
		return
		
	if (is_commander and is_hero) or is_commander:
		annoucer_sound.stream = announce_commander_killed.pick_random()
	elif is_hero:
		annoucer_sound.stream = announce_hero_killed.pick_random()
	else:
		annoucer_sound.stream = announce_squad_killed.pick_random()
		
	annoucer_sound.play()
		
func play_squad_spawn(is_commander :bool, is_hero :bool):
	if annoucer_sound.playing:
		return
		
	if (is_commander and is_hero) or is_commander:
		annoucer_sound.stream = announce_commander_spawned.pick_random()
	elif is_hero:
		annoucer_sound.stream = announce_hero_spawned.pick_random()
	else:
		annoucer_sound.stream = announce_squad_spawned.pick_random()
		
	annoucer_sound.play()
	
########################################## position manager ############################################
var tile_position_manager :TilePositionManager

func setup_unit_position_manager():
	tile_position_manager = preload("res://assets/tile_position_manager/tile_position_manager.tscn").instance()
	tile_position_manager.name = "tile_position_manager"
	add_child(tile_position_manager)
	
########################################## tile map ############################################
onready var current_tile_map_manifest_data :TileMapFileManifest = Global.current_tile_map_manifest_data
var current_tile_map_file_data :TileMapFileData

var tile_map :EditableTileMap
var nav :NavTileMap

func spawn_tile_map():
	
	# dup and assign
	current_tile_map_file_data = TileMapFileData.new()
	current_tile_map_file_data.from_dictionary(Global.current_tile_map_file_data.to_dictionary())
	
	tile_map = preload("res://addons/custom_tile_map/scenes/editable_tile_map/editable_tile_map.tscn").instance()
	tile_map.connect("on_map_ready", self, "_on_tile_map_ready")
	tile_map.name = "tile_map"
	tile_map.biom = Global.biom
	tile_map.tile_scenes = TileIndex.tiles
	add_child(tile_map)
	tile_map.load_data_map(current_tile_map_file_data)
	
	# init grandmap unit position
	tile_position_manager.init_position(current_tile_map_manifest_data.map_size)
	
func _on_tile_map_ready():
	nav = tile_map.get_nav_tile_map()
	
	# this function only be called
	# if tile map is ready and setup properly
	var map_size :int = current_tile_map_manifest_data.map_size
	var all_players = players + bot_players + [bot_bandit]
	
	for index in all_players.size():
		var p :PlayerData = all_players[index]
		blocked_tiles[p.team] = []
		
	for index in all_players.size():
		var p :PlayerData = all_players[index]
		
		var spawn_point_fort :Array = spawn_point_forts[p.spawn_position]
		var offset_edge = spawn_point_fort[1]
		var points = TileIndex.get_spawn_points(map_size, offset_edge + 1) # 4 spawn point edges, 1 center last
		player_ids[p.player_id] = p
		player_spawn_points[p.player_id] = points[p.spawn_position]
		
		setup_players_spawn_point(p, spawn_point_fort)
		
	ui.minimap.biom = Global.biom
	ui.minimap.load_data_map(current_tile_map_file_data)
	
	if is_server:
		NetworkLobbyManager.set_host_ready()
		yield(get_tree().create_timer(3), "timeout")
		
	NetworkLobbyManager.set_ready()
	
	# this for current player only
	# ajustment to camera
	var tile :TileMapData = tile_map.get_tile(player_spawn_points[current_player.player_id])
	if tile != null:
		movable_camera.translation.x = tile.pos.x + 1
		movable_camera.translation.z = tile.pos.z + 1
	
########################################## players army spawn mechanism  ############################################

func start_spawn_army():
	var armies :Array = Global.prepare_army(
		Global.current_army, 
		player_spawn_points[current_player.player_id], 
		current_player,
		Global.get_total_cards_extra_bonuses(Global.current_army_cards)
	)
	
	var is_fort = spawn_point_forts[current_player.spawn_position][0]
	
	ui.squad_spawner_ui.set_label("Preparing" if is_fort else "Entering")
	ui.squad_spawner.add_spawn_queue(armies)
	
func _on_squad_spawner_squads_ready(squads :Array):
	spawn_squads(squads)

########################################## players spawn  ############################################
var bot_bandit :PlayerData # bandit ai

onready var current_player :PlayerData = Global.current_player
onready var spawn_point_forts :Dictionary = Global.spawn_point_forts

onready var players :Array = Global.players # [PlayerData]
onready var player_ids :Dictionary = {}
onready var bot_players :Array = Global.bot_players

var player_spawn_points :Dictionary = {} # {player_id:Vector2} all players
var player_reinfoce_tiles :Dictionary = {} # {player_id:[]}

var tower_datas :Array = [] # servers spawn only
var blocked_tiles :Dictionary = {0:[]} # {team:[Vector2]}
var tower_buildings :Dictionary = {}
var camp_buildings: Array

func setup_bandit_mob():
	# this is for bot bandit
	bot_bandit = PlayerData.new()
	bot_bandit.player_network_id = 1
	bot_bandit.player_id = "bot_bandit" 
	bot_bandit.team = -1
	bot_bandit.color_idx = 10
	bot_bandit.spawn_position = 4 # default set last one
	
func setup_players_spawn_point(p :PlayerData, spawn_point_fort :Array):
	if not spawn_point_fort[0]:
		return
		
	var fort_size :int = spawn_point_fort[1]
	var fort_type :int = spawn_point_fort[2]
	var gate_state :int = spawn_point_fort[3]
	
	var point :Vector2 = player_spawn_points[p.player_id]
	
	var tiles = TileIndex.generate_player_spawn_tiles(point, fort_size)
	for id in tiles:
		var current :TileMapData = tile_map.get_tile(id)
		current.rotation_idx = 0
		current.scene_idx = 12 if (fort_type == 2) else 2
		tile_map.update_spawned_tile(current)
		nav.enable_nav_tile(0, id, true)
		
	player_reinfoce_tiles[p.player_id] = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions(), point, fort_size) + [point]
	setup_base(p, point, fort_size, fort_type, gate_state)
	
const wall_scene = preload("res://scenes/buildings/walls/wall.tscn")
const wall_ramp_scene = preload("res://scenes/buildings/walls/wall_ramp.tscn")
const stone_wall_ramp_scene = preload("res://scenes/buildings/walls/stone_wall_ramp.tscn")

const wall_corner_scene = preload("res://scenes/buildings/walls/wall_corner.tscn")
const wall_corner_ramp_scene = preload("res://scenes/buildings/walls/wall_corner_ramp.tscn")
 
const tower_scene = preload("res://scenes/buildings/tower/tower.tscn")
const stone_tower_scene = preload("res://scenes/buildings/tower/stone_tower.tscn")

const gate_scene = preload("res://scenes/buildings/gate/gate.tscn")
const gate_destroyed_scene = preload("res://scenes/buildings/gate/gate_destroyed.tscn")

const camps = [
	preload("res://scenes/buildings/camp/tent_1.tscn"),
	preload("res://scenes/buildings/camp/tent_2.tscn"),
	preload("res://scenes/buildings/camp/tent_3.tscn")
]

remotesync func _spawn_camps(datas :Array):
	for i in datas:
		var id = i[0]
		var w = camps[i[1]].instance()
		tile_map.get_tile_instance(id).add_child(w)
		nav.enable_nav_tile(0, id, false)
		w.rotation_degrees.y = i[2]
	
func setup_base(p :PlayerData, tile_id :Vector2, size :int, fort_type :int, gate_state :int):
	var rotations = [0,-90, 90, 180]
	var camp_positions = [
		Vector2.UP + Vector2.LEFT,
		Vector2.UP + Vector2.RIGHT,
		Vector2.DOWN + Vector2.LEFT,
		Vector2.DOWN + Vector2.RIGHT
	]
	
	if is_server:
		for pos in camp_positions:
			var id = tile_id + pos
			var camp = randi() % camps.size()
			camp_buildings.append([id, camp, rotations.pick_random() if (camp == 1) else 0])
		
	var datas :Array = TileIndex.generate_fort_ring(tile_id, size)
	for i in datas:
		var data :Dictionary = i
		var id = data["tile_id"]
		var rotation = data["rotation"]
		var outsides = data["outsides"]
		
		match (data["type"]):
			"wall":
				var w
				match fort_type:
					0:
						w = wall_scene.instance()
					1:
						w = wall_ramp_scene.instance()
						nav.get_nav_data(id).pos.y = 0.40 # elevation
					2:
						w = stone_wall_ramp_scene.instance()
						nav.get_nav_data(id).pos.y = 0.40 # elevation
						
				w.material = Global.player_materials[p.color_idx]
				tile_map.get_tile_instance(id).add_child(w)
				w.rotation_degrees.y = rotation
				
				for outside in outsides:
					nav.set_point_connection(0, id, outside, false)
				
			"corner":
				nav.get_nav_data(id).pos.y = 1.04 # elevation
				
				var t
				match fort_type:
					0:
						t = tower_scene.instance()
						nav.enable_nav_tile(0, id, false)
						
						var w = wall_corner_scene.instance()
						w.material = Global.player_materials[p.color_idx]
						tile_map.get_tile_instance(id).add_child(w)
						w.rotation_degrees.y = rotation
						
					1:
						t = tower_scene.instance()
						nav.enable_nav_tile(0, id, false)
						
						var w = wall_corner_ramp_scene.instance()
						w.material = Global.player_materials[p.color_idx]
						tile_map.get_tile_instance(id).add_child(w)
						w.rotation_degrees.y = rotation
						
					2:
						t = stone_tower_scene.instance()
				
				t.material = Global.player_materials[p.color_idx]
				tile_map.get_tile_instance(id).add_child(t)
				tower_buildings[id] = t
				
				for outside in outsides:
					nav.set_point_connection(0, id, outside, false)
					
				if is_server:
					var guard_tower = preload("res://data/squad_data/static_guard_tower.tres").duplicate()
					guard_tower.network_id = 1
					guard_tower.player_id = p.player_id
					guard_tower.node_name = "tower_%s_%s" % [p.player_id, Utils.create_unique_id()]
					guard_tower.current_tile = id
					guard_tower.color_idx = p.color_idx
					guard_tower.team = p.team
					tower_datas.append(guard_tower)
					
			"gate":
				if gate_state in [1, 2]:
					var g = gate_scene.instance()
					g.unit_position = tile_position_manager.get_positions()
					g.material = Global.player_materials[p.color_idx]
					g.keep_open = (gate_state == 2)
					tile_map.get_tile_instance(id).add_child(g)
					g.rotation_degrees.y = rotation
					g.tile_ids = outsides + [id]
					g.team = p.team
					
					# append to blocked tile
					# to team that nots in this gate
					if gate_state == 1:
						for team in blocked_tiles.keys():
							if team != p.team:
								blocked_tiles[team].append(id)
								
				if gate_state == 3:
					var g = gate_destroyed_scene.instance()
					g.material = Global.player_materials[p.color_idx]
					tile_map.get_tile_instance(id).add_child(g)
					g.rotation_degrees.y = rotation
					
					
func _destroy_tower(tile :Vector2):
	if tower_buildings.has(tile):
		tower_buildings[tile].destroy()
	
########################################## gameplay win condition  ############################################
var is_end :bool = false

func _check_wining_team():
	if not is_server or is_end:
		return
		
	var teams :Dictionary = {} # {int:0}
	for squad in squads:
		if squad.team == -1: # exclude bot bandit
			continue
			
		teams[squad.team] = true
		
	# nobody win
	if teams.empty():
		is_end = true
		rpc("_on_end", -1)
		return
	
	# one team win
	if teams.size() == 1:
		is_end = true
		rpc("_on_end", teams.keys().front())
		return
	
remotesync func _on_end(team :int):
	is_end = true
	on_end(team)
	
func on_end(team :int):
	Global.is_win = (current_player.team == team)
	ui.hide_ui()
	
	yield(get_tree().create_timer(5),"timeout")
	
	Global.current_root = null
	Global.change_scene("res://menus/battle_result/battle_result.tscn", true, 7 if Global.is_win else 8)
	
########################################## camera  ############################################
var movable_camera :MovableCamera
var orbital_camera :MovableCamera

func spawn_movable_camera():
	movable_camera = preload("res://assets/camera/movable_camera.tscn").instance()
	movable_camera.name = "movable_camera"
	add_child(movable_camera)
	movable_camera.translation = Vector3(0, 3, 0)
	movable_camera.rotation_degrees.y = 45
	
	orbital_camera = preload("res://assets/camera/orbital_camera.tscn").instance()
	orbital_camera.name = "orbital_camera"
	add_child(orbital_camera)
	
	movable_camera.camera.current = true
	
##########################################  floor interaction  ############################################
var enviroment :Node

func spawn_enviroment():
	enviroment = preload("res://assets/enviroment/outside_enviroment.tscn").instance()
	add_child(enviroment)
	
##########################################  floor interaction  ############################################
var clickable_floor :ClickableFloor

func setup_clickable_floor():
	clickable_floor = preload("res://assets/clickable_floor/clickable_floor.tscn").instance()
	clickable_floor.connect("on_floor_clicked", self, "_on_floor_clicked")
	clickable_floor.name = "clickable_floor"
	add_child(clickable_floor)

func _on_floor_clicked(pos :Vector3):
	if ui.on_cinematic_mode:
		return
		
	var tile = tile_map.get_closes_tile(pos)
	_move_squad_to(tile, setting.lock_command)
	
########################################## Tap  ############################################
var tap :TapIndicator

func set_tap():
	tap = preload("res://assets/tap/tap.tscn").instance()
	add_child(tap)

########################################## UI  ############################################
var ui :GameplayUi
onready var setting :SettingData = Global.setting_data

func setup_ui():
	ui = preload("res://menus/gameplay/ui/ui.tscn").instance()
	ui.name = "ui"
	ui.connect("reset_camera", self, "_on_ui_reset_camera")
	ui.connect("exit", self, "on_back_pressed")
	ui.connect("cinematic_view", self, "_on_ui_cinematic_view")
	
	ui.player_squads = player_squads
	ui.selected_squads = selected_squads
	
	add_child(ui)
	
	ui.scoreboard.init_scoreboard(players + bot_players)
	
	ui.squad_spawner.connect("on_squads_ready", self, "_on_squad_spawner_squads_ready")
	ui.route_button.connect("pressed", self, "_on_ui_route_button_pressed")
	ui.ability_button.connect("pressed", self, "_on_use_ability")
	
	var selection_buttons = [
		ui.selection_button_all,
		ui.selection_button_cav,
		ui.selection_button_inf,
		ui.selection_button_rng
	]
	for idx in selection_buttons.size():
		selection_buttons[idx].connect("pressed", self, "_on_selection_button_pressed", [idx])

	var map_size :int = current_tile_map_manifest_data.map_size
	ui.movable_camera_ui.target = movable_camera
	ui.movable_camera_ui.camera_limit_bound = Vector3(map_size, 0, map_size)
	ui.movable_camera_ui.center_pos = tile_map.global_position
	ui.movable_camera_ui.move_speed = setting.camera_move_speed
	ui.movable_camera_ui.zoom_speed = setting.camera_zoom_speed
	
	ui.orbital_camera_ui.rotate_speed = setting.camera_rotation_speed
	ui.orbital_camera_ui.zoom_speed= setting.camera_zoom_speed
	ui.orbital_camera_ui.orbit_pivot = orbital_camera
	ui.orbital_camera_ui.camera = orbital_camera.camera
	ui.orbital_camera_ui.camera.translation.z = 2.5
	
	ui.movable_camera_minimap.target = movable_camera
	ui.movable_camera_minimap.camera_limit_bound = Vector3(map_size, 0, map_size)
	ui.movable_camera_minimap.center_pos = tile_map.global_position
	
	ui.log_event.current_player = current_player
	
func _on_setting_updated(d :SettingData):
	ui.movable_camera_ui.move_speed = d.camera_move_speed
	ui.movable_camera_ui.zoom_speed= d.camera_zoom_speed
	
	ui.orbital_camera_ui.rotate_speed = d.camera_rotation_speed
	ui.movable_camera_ui.zoom_speed= d.camera_zoom_speed
	
func _on_ui_reset_camera():
	movable_camera.rotation_degrees.y = 45
	
func _on_ui_route_button_pressed():
	var dup :Array = selected_squads.duplicate() # must use dup pointer
	if dup.empty():
		return
		
	if not ui_sound.playing and randf() < 0.12:
		ui_sound.stream = buff
		ui_sound.stream = saya_akan_kembali
		ui_sound.play()
		
	for squad in dup:
		squad.retreat()
		squad.click() # unselected
		
func _on_use_ability():
	var squad :BaseSquad = ui.squad_with_ability
	var data :SquadData = squad_datas[squad]
	AbilityHandle.use_squad_ability(self, current_player, squad, tile_position_manager, data.extra)
	
	if not setting.lock_command:
		squad.click() # unselected
		
	if not ui_sound.playing:
		ui_sound.stream = buff
		if squad.squad_ability_idx == 18:
			ui_sound.stream = regroup
			
		if randf() < 0.15:
			ui_sound.stream = memes.pick_random()
		
		ui_sound.play()
		
func _on_selection_button_pressed(idx :int):
	# index 0 audio dont exist
	if idx > 0 and selected_squads.empty():
		unit_sound.stream = selection_group[idx].pick_random()
		unit_sound.play()
		
	ui.select_all_squad(idx)
	
func _on_ui_cinematic_view(cinematic_mode :bool):
	if cinematic_mode:
		set_process(false)
		movable_camera.translation = orbital_camera.translation
		var pos = movable_camera.translation * Vector3(1,0,1)
		
		tile_map.update_camera_location(Vector2(pos.x, pos.z), true)
		
		yield(get_tree(),"idle_frame")
		set_process(true)
	
########################################## squad  ############################################
var squads :Array = []
var squad_datas :Dictionary = {}

# current player
var player_squads :Array = []
var selected_squads :Array = []

# list of player got screw of their commander ded
var player_debuf :Array = [] 

func spawn_squads(s :Array):
	var list_bytes :Array = []
	for i in s:
		list_bytes.append(i.to_bytes())
		
	rpc("_spawn_squads", list_bytes)
	
func spawn_squad(d :SquadData):
	rpc("_spawn_squad", d.to_bytes())
	
remotesync func _spawn_squads(list_bytes :Array):
	for bytes in list_bytes:
		_spawn_squad(bytes)
		
remotesync func _spawn_squad(bytes :PoolByteArray):
	var data :SquadData = SquadData.new()
	data.from_bytes(bytes)
	
	data.biom = Global.biom
	
	var squad :BaseSquad = EntityIndex.squads[data.scene_idx].instance()
	squad.name = data.node_name
	squad.network_id = data.network_id
	squad.current_tile = data.current_tile
	squad.blocked_tiles = blocked_tiles[data.team]
	
	squad.player_id = data.player_id
	squad.unit_name = data.squad_name
	squad.team = data.team
	squad.color = EntityIndex.player_colors[data.color_idx]
	squad.speed = data.speed()

	# squad data
	squad.member_scene = EntityIndex.members[data.member_scene_idx]
	squad.can_attack = true
	squad.turning_speed = data.turning_speed
	squad.melee_attack_speed = data.melee_attack_speed()
	squad.range_attack_speed = data.range_attack_speed()
	squad.formation_density = data.formation_density
	squad.spotting_range = data.spotting_range
	squad.attack_range = data.attack_range()
	
	# apply debuf, 50% slower attack speed
	if player_debuf.has(data.player_id):
		squad.melee_attack_speed += squad.melee_attack_speed
		squad.range_attack_speed += squad.range_attack_speed
		
	var member_hp = data.member_hp()
	
	# squad member
	squad.member_headgear = EntityIndex.head_armors[data.member_headgear_idx]
	squad.member_armor = EntityIndex.armors[data.member_armor_idx]
	squad.member_shield = EntityIndex.shields[data.member_shield_idx]
	squad.member_melee_weapon = EntityIndex.melee_weapons[data.member_melee_weapon_idx]
	squad.member_range_weapon = EntityIndex.range_weapons[data.member_range_weapon_idx]
	squad.member_material = Global.player_materials[data.color_idx]
	squad.member_hp = member_hp
	squad.member_max_hp = member_hp
	squad.heal_amount = data.heal_amount()
	squad.total_member = data.total_member
	squad.squad_role = data.squad_role
	squad.squad_icon = EntityIndex.squad_icon[data.icon_idx]
	squad.squad_attribute = data.squad_attribute()
	squad.squad_ability_idx = data.squad_ability_idx
	squad.rapid_fire_mode = (data.range_fire_mode == 1) and (not data.is_hero)
	squad.is_hero = data.is_hero
	
	squad.banner_icon_idx = data.banner_icon_idx
	squad.banner_icon = EntityIndex.banner_icons[data.banner_icon_idx]

	# extra ui
	squad.enable_blood = setting.extra_effect
	squad.enable_squad_tile_indicator = setting.show_unit_tile
	squad.show_move_to_indicator = squad.player_id == current_player.player_id

	# for floating info
	squad.camera = movable_camera.camera
	squad.unit_indexing = tile_position_manager.get_unit_indexing()
	
	if data.is_hero:
		squad.connect("on_squad_taking_damage", self, "_on_hero_taking_damage")
	
	squad.connect("on_squad_taking_damage", self, "_on_squad_taking_damage")
	squad.connect("on_squad_member_dead", self, "_on_squad_member_dead", [data])
	squad.connect("on_squad_member_resurect", self, "_on_squad_member_resurect")
	#squad.connect("on_unit_spotted", self, "_on_unit_spotted")
	squad.connect("on_unit_clicked", self, "_on_unit_clicked")
	squad.connect("on_current_tile_updated", self, "_on_current_tile_updated")
	#squad.connect("on_finish_travel", self, "_on_finish_travel")
	squad.connect("on_squad_dead", self, "_on_squad_dead", [data])
	squad.connect("on_squad_set_modifier", self, "_on_squad_set_modifier")
	squad.connect("on_squad_modifier_clear", self, "_on_squad_modifier_clear")
	
	if squad is CavalrySquad:
		squad.use_heavy_armor = data.member_armor_idx in EntityIndex.heavy_armor_idxs
		squad.charge_damage = data.charge_damage()
		squad.connect("on_cav_charge", self, "_on_cav_charge")
		
	if squad is SiegeEngineSquad:
		squad.attack_range = data.siege_engine_attack_range
		squad.range_attack_speed = data.siege_engine_attack_speed
		
	#var my_team = (data.team == current_player.team)
	squad.enable_spotting = false
	#squad.set_hidden(not my_team)
	
	squad.set_hidden(false)
	add_child(squad)
	squad.global_transform.origin = nav.get_pos_v3(data.current_tile)
	
	if data.current_tile != Vector2.ZERO:
		squad.look_at(Vector3.ZERO, Vector3.UP)
	
	_on_squad_spawned(squad, data)
	
func _on_squad_spawned(squad :BaseSquad, data :SquadData):
	tile_position_manager.add_to_position(squad, squad.current_tile)
	
	 # default layer
	squad.nav_layer = 0
	squad.nav = nav
	squad.unit_position = tile_position_manager.get_positions()
	squad.update_spotting()
	
	ui.minimap.add_object(squad, squad.color)
	
	if squad is GuardTowerSquad:
		var p :PlayerData = player_ids[squad.player_id]
		if spawn_point_forts[p.spawn_position][2] != 2:
			squad.nav_layer = 1 # diffrent path
			
		return
		
	ui.scoreboard.register_squad(player_ids[squad.player_id], data)
	
	squad_datas[squad] = data
	squads.append(squad)
	
	ui.add_squad_floating_info(squad, data, current_player)
	
	# use current spawn tile as reinfoce tile
	if player_reinfoce_tiles.has(squad.player_id):
		squad.reinfoce_tiles = player_reinfoce_tiles[squad.player_id]
	
	# add as card
	if squad.player_id == current_player.player_id:
		player_squads.append(squad)
		ui.add_squad_card(squad, data)
		play_squad_spawn(data.is_commander,data.is_hero)
		
	# start cooldown
	if squad.squad_ability_idx != 0:
		squad.start_ability_cooldown(AbilityHandle.squad_abilities[squad.squad_ability_idx]["cooldown"])
		
	# auto move after spawn
	if data.current_tile != data.move_tile:
		squad.move_to(data.move_tile)
	
func _move_squad_to(tile :TileMapData, lock_command :bool):
	if selected_squads.empty():
		return
		
	var dup = selected_squads.duplicate() # must use dup pointer
	
	if dup.empty():
		return
		
	if not is_instance_valid(dup[0]):
		return
		
	# formations
	var s :BaseSquad = dup[0]
	var tiles :Array = [tile.id]
	
	if dup.size() > 1:
		tiles += TileMapUtils.get_astar_adjacent_tile(
			nav.get_astar(s.nav_layer), nav.get_navigation_id(s.nav_layer, tile.id), 2
		)
		
	unit_move_response()
	
	var idx = 0
	var tile_id
	for squad in dup:
		if idx <= tiles.size() - 1:
			tile_id = tiles[idx]
			
		squad.move_to(tile_id)
		if not lock_command:
			squad.click() # to unselect
			
		tap.tap(tile_map.get_tile(tile_id).pos, (1 if squad.attack_move else 0))
		idx += 1
		
func _on_hero_taking_damage(squad :BaseSquad, amount :int):
	pass
	
func _on_squad_taking_damage(squad :BaseSquad, amount :int):
	if setting.show_feed:
		ui.log_event.add_log_damage(squad, amount)
	
func _on_squad_member_dead(squad :BaseSquad, member :SquadMember, data :SquadData):
	var is_guard_tower = squad is GuardTowerSquad
	
	if setting.show_feed:
		ui.log_event.add_log_member_lost(squad, member)
		
	if player_ids.has(squad.player_id) and (not is_guard_tower):
		ui.scoreboard.add_dead(player_ids[squad.player_id], data, 1)
	
	var from :BaseSquad = get_node_or_null(member.attacked_by)
	if not is_instance_valid(from):
		return
		
	var conditions = [
		not player_ids.has(from.player_id),
		not squad_datas.has(from),
		from is GuardTowerSquad
	]
	if conditions.has(true):
		return
		
	var from_player :PlayerData = player_ids[from.player_id]
	var from_squad :SquadData = squad_datas[from]
	if from.team == squad.team:
		ui.scoreboard.add_friendly_fire(from_player, from_squad, 1)
		
	else:
		ui.scoreboard.add_kill(from_player, from_squad, 1)
		
	# all squad get debuf if member is banerman die
	# handled and debuff invoked to all squad by server
	if member.is_bannerman and is_server:
		var player_id :String = squad.player_id
		for s in squads:
			if s.player_id == player_id:
				s.set_modifiers(EntityIndex.banner_debuf[squad.banner_icon_idx])
	
const modifier_indicator = preload("res://assets/squad_buff_debuff_indicator/squad_buff_debuff_indicator.tscn")

func _on_squad_set_modifier(squad :BaseSquad, i :Array):
	var type :int = i[0]
	var value :float = clamp(i[1], -0.99, 0.99)
	var icon_idx :int = i[3]
	
	var is_buff :bool = value > 0
	if type == squad.modifier_damage_receive:
		is_buff = value < 0
		
	if setting.show_feed:
		ui.log_event.add_log_squad_add_modifier(squad, type, value, is_buff)
		
	if icon_idx == 0:
		return
		
	var ind = modifier_indicator.instance()
	ind.icon = AbilityHandle.buff_debuff_icons[icon_idx]
	ind.is_buff = is_buff
	ind.squad = squad
	add_child(ind)
	
	if squad.player_id == current_player.player_id and not is_buff:
		if not ui_sound.playing:
			ui_sound.stream = debuff
			
			if randf() < 0.14:
				ui_sound.stream = memes2.pick_random()
				
			ui_sound.play()
	
func _on_squad_modifier_clear(squad :BaseSquad):
	var is_player = squad.player_id == current_player.player_id
	var icn = AbilityHandle.buff_debuff_icons[AbilityHandle.icon_horn] if is_player else AbilityHandle.buff_debuff_icons[AbilityHandle.icon_zap]
	var ind = modifier_indicator.instance()
	ind.icon = icn
	ind.is_buff = is_player
	ind.squad = squad
	add_child(ind)
	
func _on_squad_member_resurect(squad :BaseSquad, member):
	pass
	
func _on_unit_spotted(squad :BaseSquad):
	pass
	
func _on_unit_clicked(clicked_squad :BaseSquad):
	# if squad own by player
	if clicked_squad in player_squads:
		if clicked_squad in selected_squads:
			selected_squads.erase(clicked_squad)
		else:
			selected_squads.append(clicked_squad)
			unit_select_response(true)
			
		ui.selected_squads_updated()
		return
		
	# if squad is enemy squad
	if clicked_squad.team != current_player.team:
		if selected_squads.empty():
			return
			
		if not ui_sound.playing:
			ui_sound.stream = attack_sfx
			if randf() < 0.07: # 7% chance of pria solo
				var s = [memes[2], memes[3]].pick_random()
				ui_sound.stream = s
				
			ui_sound.play()
			
		unit_attacking_response()
		
		var dup = selected_squads.duplicate() # must use dup pointer
		for s in dup:
			tap.tap(tile_map.get_tile(clicked_squad.current_tile).pos, 1)
			s.attack_move = false
			s.chase_enemy = clicked_squad
			s.chase_target()
			
			if not setting.lock_command:
				s.click() # to unselect
	
func _on_current_tile_updated(squad :BaseSquad, from_id :Vector2, to_id :Vector2):
	tile_position_manager.update_position(squad, from_id, to_id)
	
func _on_finish_travel(squad, last_id, current_id):
	pass
	
func _on_squad_dead(squad :BaseSquad, data :SquadData):
	if player_ids.has(squad.player_id):
		ui.scoreboard.set_squad_dead(player_ids[squad.player_id], data)
	
	ui.minimap.remove_object(squad)
	tile_position_manager.remove_from_position(squad, squad.current_tile)
	
	if squads.has(squad):
		squads.erase(squad)
		
	if squad_datas.has(squad):
		squad_datas.erase(squad)
		
	_check_wining_team()
	
	if setting.show_feed:
		ui.log_event.add_log_squad_dead(squad)
	
	# cheap ass way to detect commander
	var is_commander :bool = data.is_commander
	var is_hero :bool = data.is_hero

	# apply debuf, 50% slower attack speed
	if is_commander and not player_debuf.has(squad.player_id):
		player_debuf.append(squad.player_id)
		for s in squads:
			if s.player_id == squad.player_id:
				s.melee_attack_speed += s.melee_attack_speed
				s.range_attack_speed += s.range_attack_speed
	
	# confirm the lost was yours
	if squad.player_id == current_player.player_id:
		if selected_squads.has(squad):
			selected_squads.erase(squad)
			ui.selected_squads_updated()
			
		player_squads.erase(squad)
		ui.remove_squad_card(squad)
		
		play_squad_lost(is_commander, is_hero, squad is GuardTowerSquad)
		
	# confirm the kill was yours
	if squad.team != current_player.team:
		var attacked_by :BaseSquad = get_node_or_null(squad.attacked_by)
		if is_instance_valid(attacked_by):
			if attacked_by.player_id == current_player.player_id:
				play_squad_killed(is_commander, is_hero)
				
	if squad.floating_info:
		squad.floating_info.visible = false
	
	yield(get_tree().create_timer(1),"timeout")
	
	# respawn squad of dead tower guard
	if squad is GuardTowerSquad:
		_destroy_tower(squad.current_tile)
		
	squad.queue_free()

	
func _on_cav_charge(squad : CavalrySquad):
	if squad.player_id == current_player.player_id:
		unit_charged_impact(true)

var corpses = []

func stash_corpses(pivot :Spatial, current_tile :Vector2):
	var old_global_transform = pivot.global_transform
	var old_global_rot = pivot.global_transform.basis

	var tile :BaseTile = tile_map.get_tile_instance(current_tile)
	var corpse = pivot.duplicate()
	tile.add_child(corpse)
	
	corpse.global_transform = old_global_transform
	corpse.global_transform.basis = old_global_rot
	corpse.translation.y = 0.25

	if corpses.size() > 25:
		var f = corpses.front()
		corpses.pop_front()
		f.queue_free()
		
	corpses.append(corpse)
	
func has_squad_space() -> bool:
	return player_squads.size() < Global.max_army_size
	
# broadcast command by any peer
func force_command(_type_command :int, _squads :Array):
	rpc("_force_command", _type_command, _squads)
	
# broadcast to all, check if they own this unit by network id
# just call it function locally to avoid burden network
remotesync func _force_command(_type_command :int, _squads :Array):
	var current_player_network_id :int = NetworkLobbyManager.get_id()
	
	for path in _squads:
		var squad :BaseSquad = get_node_or_null(path)
		if not is_instance_valid(squad):
			continue
			
		if squad.network_id != current_player_network_id:
			continue
			
		match (_type_command):
			0: # stop squad
				squad.stop()
				
			1: # retreat squad
				squad.retreat()
				
			2: # revive all dead member 
				# total member all - total alive 
				var total_dead :int = squad.total_member - squad.member_alive
				squad.resurecting(total_dead)
				
			3: # instant cooldown
				squad.start_ability_cooldown(1.0)
				
			4: # heal all squad member 
				squad.healing()
				
			5: # stop squad then re assign the target randomly
				squad.stop()
				
				if not squads.empty():
					squad.attack_move = false
					squad.chase_enemy = squads.pick_random()
					squad.chase_target()
				
# special spawning & cursing bullcrapt
# [type_sigil :int, at_tile :Vector2, duration :float]
func spawn_sigils(datas :Array):
	rpc("_spawn_sigils", datas)
	
remotesync func _spawn_sigils(datas :Array):
	for data in datas:
		var sigil_color :Color = data[0] # 0:curse, 1:gate
		var at_tile :Vector2 = data[1]
		var duration :float = data[2]
		
		var sigil = preload("res://assets/sigil/sigil.tscn").instance()
		sigil.color = sigil_color
		add_child(sigil)
		sigil.translation = nav.get_pos_v3(at_tile)
		
func spawn_explosions(datas :Array):
	rpc("_spawn_explosions", datas)
	
remotesync func _spawn_explosions(datas :Array):
	for data in datas:
		var explode_scene :PackedScene
		var type_exp :int = data[0] # 0
		var at_tile :Vector2 = data[1]
		
		match type_exp:
			0:
				explode_scene = preload("res://assets/explosion/explosion.tscn")
				
		var explode = explode_scene.instance()
		explode.connect("explode", self, "_on_explode", [explode])
		add_child(explode)
		explode.translation = nav.get_pos_v3(at_tile)
		explode.explode()
	
func _on_explode(e):
	e.queue_free()
	
		
# special order, off map artilery
func drop_projectiles(type_projectile :int, targets :Array, by :NodePath):
	rpc("_drop_projectiles", NetworkLobbyManager.get_id(), type_projectile, targets, by)
	
remotesync func _drop_projectiles(from_id :int, type_projectile :int, targets :Array, by :NodePath):
	var _projectile_scene :PackedScene
	
	match type_projectile:
		0:
			_projectile_scene = preload("res://scenes/projectiles/boulder.tscn")
		1:
			_projectile_scene = preload("res://scenes/projectiles/balista_bolt.tscn")
			
	var is_master = (from_id == NetworkLobbyManager.get_id())
	for tile in targets:
		_on_projectile_droping(_projectile_scene, type_projectile, tile, by, is_master)
		yield(get_tree().create_timer(1), "timeout")

func _on_projectile_droping(scene :PackedScene, type_projectile :int, tile :Vector2, by :NodePath, is_master :bool):
	var target_position = nav.get_pos_v3(tile)
	var _projectile :BaseProjectile = scene.instance()
	add_child(_projectile)
	_projectile.translation = target_position + (Vector3.UP * 15) + (Vector3.FORWARD * 10)
	_projectile.to = target_position + Vector3.ONE * rand_range(-0.5,0.5)
	_projectile.launch()
	
	if not is_master:
		return
		
	yield(_projectile, "on_reach")
	
	var damage :int = 0
	var splash :bool = false
	match type_projectile:
		0:
			damage = 65
			splash = true
		1:
			damage = 45
	
	_on_projectile_impact(tile, damage, splash, by)
	
func _on_projectile_impact(center_tile_id :Vector2, damage :int, splash :bool, by :NodePath):
	var unit_position = tile_position_manager.get_positions()
	var tiles :Array = [center_tile_id]
	
	if splash:
		tiles += TileMapUtils.get_adjacent_tiles(
			TileMapUtils.get_directions(), center_tile_id, 1
		)
	
	for tile_id in tiles:
		if not unit_position.has(tile_id):
			continue
			
		var unit_positions :Array = unit_position[tile_id]
		if unit_positions.empty():
			continue
			
		_on_projectile_impact_damage(unit_positions, damage, by)

func _on_projectile_impact_damage(unit_positions:Array, dmg :int, by :NodePath):
	for enemy_squad in unit_positions:
		if not is_instance_valid(enemy_squad):
			continue
			
		var members :Array = enemy_squad.get_members()
		if members.empty():
			continue
			
		# set damage to random member
		var t = randi() % members.size()
		t = int(clamp(t, 1, members.size()))
		
		for _i in t:
			var idx :int = enemy_squad.get_member_index(members.pick_random())
			enemy_squad.take_damage(dmg, idx, by)
	
func drop_grenade(at_tile :Vector2, by :NodePath):
	rpc("_drop_grenade", at_tile, 5)
	
	yield(get_tree().create_timer(5), "timeout")
	
	var ranges :Array = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions(), at_tile, 1) + [at_tile]
	var target_squads :Array = AbilityHandle.get_squad_in_range(tile_position_manager.get_positions(), ranges)
	
	for s in target_squads:
		var dmg :int = int(rand_range(40, 60))
		var members :Array = s.get_members(true)
		for idx in members.size():
			s.take_damage(dmg, idx, by)
		
remotesync func _drop_grenade(at_tile :Vector2, time :float):
	var _grenades :Array = []
	var _tile :BaseTile = tile_map.get_tile_instance(at_tile)
	var _offsets = [
		Vector3.ZERO, Vector3.ZERO + Vector3.LEFT,  Vector3.ZERO + Vector3.RIGHT,
		Vector3.FORWARD + Vector3.LEFT, Vector3.FORWARD, Vector3.FORWARD + Vector3.RIGHT,
		Vector3.BACK + Vector3.LEFT, Vector3.BACK,Vector3.BACK + Vector3.RIGHT,
	]
	
	for i in _offsets:
		var g = preload("res://scenes/equipment/weapons/grenade/grenade.tscn").instance()
		_tile.add_child(g)
		g.translation += i * 0.35
		_grenades.append(g)
	
	yield(get_tree().create_timer(time), "timeout")
	
	_spawn_explosions([[0, at_tile]]) # just call
	
	for i in _grenades:
		i.queue_free()
		
	_grenades.clear()

















