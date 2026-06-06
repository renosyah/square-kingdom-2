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
const attack_sfx = preload("res://assets/sounds/gameplay/attack.wav")
const saya_akan_lawan = preload("res://assets/sounds/gameplay/saya_akan_lawan.wav")

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
const announce_commander_killed = [
	preload("res://assets/sounds/announcement/commander_kill_1.wav"), preload("res://assets/sounds/announcement/commander_kill_2.wav"), preload("res://assets/sounds/announcement/commander_kill_3.wav"), preload("res://assets/sounds/announcement/commander_kill_4.wav"), preload("res://assets/sounds/announcement/commander_kill_5.wav"), preload("res://assets/sounds/announcement/commander_kill_6.wav")
]
const announce_commander_lost = [
	preload("res://assets/sounds/announcement/commander_lost_1.wav"), preload("res://assets/sounds/announcement/commander_lost_2.wav"), preload("res://assets/sounds/announcement/commander_lost_3.wav"), preload("res://assets/sounds/announcement/commander_lost_4.wav"), preload("res://assets/sounds/announcement/commander_lost_5.wav"), preload("res://assets/sounds/announcement/commander_lost_6.wav")
]
const announce_squad_spawned = [
	preload("res://assets/sounds/announcement/reinforcement_1.wav"), preload("res://assets/sounds/announcement/reinforcement_2.wav"), preload("res://assets/sounds/announcement/reinforcement_3.wav"), preload("res://assets/sounds/announcement/reinforcement_4.wav"), preload("res://assets/sounds/announcement/reinforcement_5.wav"), preload("res://assets/sounds/announcement/reinforcement_6.wav")
]
const announce_commander_spawned = [
	preload("res://assets/sounds/announcement/commander_arrive _1.wav"), preload("res://assets/sounds/announcement/commander_arrive _2.wav"), preload("res://assets/sounds/announcement/commander_arrive _3.wav"), preload("res://assets/sounds/announcement/commander_arrive _4.wav"), preload("res://assets/sounds/announcement/commander_arrive _5.wav"), preload("res://assets/sounds/announcement/commander_arrive _6.wav")
]

var ui_sound :AudioStreamPlayer
var unit_sound :AudioStreamPlayer
var annoucer_sound :AudioStreamPlayer

onready var announce_killed_idx :int = randi() % announce_squad_lost.size()
onready var announce_lost_idx :int = randi() % announce_squad_lost.size()

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
	
func play_squad_lost(is_commander :bool):
	if announce_lost_idx > (announce_squad_lost.size() - 1):
		announce_lost_idx = 0
		
	if not annoucer_sound.playing:
		var v = announce_commander_lost[announce_lost_idx] if is_commander else announce_squad_lost[announce_lost_idx]
		annoucer_sound.stream = v
		annoucer_sound.play()
	
	announce_lost_idx += 1

func play_squad_killed(is_commander :bool):
	if announce_killed_idx > (announce_squad_killed.size() - 1):
		announce_killed_idx = 0
		
	if not annoucer_sound.playing:
		var v = announce_commander_killed[announce_killed_idx] if is_commander else announce_squad_killed[announce_killed_idx]
		annoucer_sound.stream = v
		annoucer_sound.play()
	
	announce_killed_idx += 1
	
func play_squad_spawn(is_commander :bool):
	if not annoucer_sound.playing:
		annoucer_sound.stream = announce_commander_spawned.pick_random() if is_commander else announce_squad_spawned.pick_random()
		annoucer_sound.play()
		
########################################## position manager ############################################
var tile_position_manager :TilePositionManager

func setup_unit_position_manager():
	tile_position_manager = preload("res://assets/tile_position_manager/tile_position_manager.tscn").instance()
	tile_position_manager.name = "tile_position_manager"
	add_child(tile_position_manager)
	
########################################## tile map ############################################
onready var current_tile_map_manifest_data :TileMapFileManifest = Global.current_tile_map_manifest_data
onready var current_tile_map_file_data :TileMapFileData = Global.current_tile_map_file_data

var tile_map :EditableTileMap
var nav :NavTileMap

func spawn_tile_map():
	tile_map = preload("res://addons/custom_tile_map/scenes/editable_tile_map/editable_tile_map.tscn").instance()
	tile_map.connect("on_map_ready", self, "_on_tile_map_ready")
	tile_map.name = "tile_map"
	tile_map.tile_scenes = TileIndex.tiles
	add_child(tile_map)
	tile_map.load_data_map(current_tile_map_file_data)
	
	# init grandmap unit position
	tile_position_manager.init_position(current_tile_map_manifest_data.map_size)
	
func _on_tile_map_ready():
	nav = tile_map.get_nav_tile_map()
	
	setup_bandit_mob()
	
	# this function only be called
	# if tile map is ready and setup properly
	setup_players_spawn_points(Global.enable_fort)
	
	ui.route_button.disabled = not Global.enable_fort
	ui.minimap.load_data_map(current_tile_map_file_data)
	
	if is_server:
		NetworkLobbyManager.set_host_ready()
		yield(get_tree().create_timer(3), "timeout")
		
	NetworkLobbyManager.set_ready()
	
########################################## players army spawn mechanism  ############################################

func start_spawn_army():
	var armies :Array = Global.prepare_army(
		Global.current_army, 
		player_spawn_points[current_player.player_id], 
		current_player
	)
	ui.squad_spawner.add_spawn_queue(armies)
	
func _on_squad_spawner_squads_ready(squads :Array):
	spawn_squads(squads)

########################################## players spawn  ############################################
var bot_bandit :PlayerData # bandit ai

onready var current_player :PlayerData = Global.current_player

onready var players :Array = Global.players # [PlayerData]
onready var player_ids :Dictionary = {}
onready var bot_players :Array = Global.bot_players

var player_spawn_points :Dictionary = {} # {player_id:Vector2} all players
var player_reinfoce_tiles :Dictionary = {} # {player_id:[]}

var tower_datas :Array = [] # servers spawn only

func setup_bandit_mob():
	# this is for bot bandit
	bot_bandit = PlayerData.new()
	bot_bandit.player_network_id = 1
	bot_bandit.player_id = "bot_bandit" 
	bot_bandit.team = -1
	bot_bandit.color_idx = 10
	bot_bandit.spawn_position = 4 # default set last one

func setup_players_spawn_points(spawn_fort :bool = false):
	var map_size :int = current_tile_map_manifest_data.map_size
	var points = TileIndex.get_spawn_points(map_size, 3) # 4 spawn point edges, 1 center last
	var all_players = players + bot_players + ([bot_bandit] if Global.enable_bandit else [])
	
	# replace all tiles with dirt of bases
	if spawn_fort:
		for index in all_players.size():
			var p :PlayerData = all_players[index]
			var tiles = TileIndex.generate_player_spawn_tiles(points[p.spawn_position])
			for id in tiles:
				var current :TileMapData = tile_map.get_tile(id)
				current.rotation_idx = 0
				current.scene_idx = 2
				tile_map.update_spawned_tile(current)
		
	# register player ids
	# spawn their bases
	for index in all_players.size():
		var p :PlayerData = all_players[index]
		var point :Vector2 = points[p.spawn_position]
		player_ids[p.player_id] = p
		player_spawn_points[p.player_id] = point
		
		if spawn_fort:
			player_reinfoce_tiles[p.player_id] = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions(), point, 2) + [point]
			setup_base(p, point)
		
	# this for current player only
	# ajustment to camera
	var tile :TileMapData = tile_map.get_tile(player_spawn_points[current_player.player_id])
	if tile == null:
		return
	
	movable_camera.translation.x = tile.pos.x + 1
	movable_camera.translation.z = tile.pos.z + 1
	
func setup_base(p :PlayerData, tile_id :Vector2):
	var wall_scene = preload("res://scenes/buildings/walls/wall.tscn")
	var wall_corner_scene = preload("res://scenes/buildings/walls/wall_corner.tscn")
	
	var corners = [
		Vector2.UP + Vector2.RIGHT, # top - right
		Vector2.UP + Vector2.LEFT, # top - left
		Vector2.DOWN + Vector2.RIGHT, # down - right
		Vector2.DOWN + Vector2.LEFT, # down - left
	]
	var walls = [
		corners[0] * 2 + Vector2.LEFT, corners[0] * 2 + Vector2.DOWN,
		corners[1] * 2 + Vector2.RIGHT, corners[1] * 2 + Vector2.DOWN,
		corners[2] * 2 + Vector2.LEFT, corners[2] * 2 + Vector2.UP,
		corners[3] * 2 + Vector2.RIGHT, corners[3] * 2 + Vector2.UP
	]
	var wall_orientation = [
		0, -90,
		0, 90,
		180, -90,
		180, 90
	]
	var wall_nav_reassign = {
		walls[0] : [Vector2.DOWN,Vector2.LEFT], walls[1] : [Vector2.DOWN, Vector2.LEFT],
		walls[2] : [Vector2.DOWN,Vector2.RIGHT], walls[3] : [Vector2.DOWN, Vector2.RIGHT],
		walls[4] : [Vector2.UP,Vector2.LEFT], walls[5] : [Vector2.UP, Vector2.LEFT],
		walls[6] : [Vector2.UP,Vector2.RIGHT], walls[7] : [Vector2.UP, Vector2.RIGHT],
	}
	
	for key in wall_nav_reassign.keys():
		var points = []
		for i in wall_nav_reassign[key]:
			points.append(tile_id + i + key)
			
		nav.reconnect_point(tile_id + key, points, 0)
		
	for idx in walls.size():
		var tile :Vector2 = tile_id + walls[idx]
		var w = wall_scene.instance()
		w.material = Global.player_materials[p.color_idx]
		tile_map.get_tile_instance(tile).add_child(w)
		w.rotation_degrees.y = wall_orientation[idx]
		
	var wall_corner_orientation = [
		-90, 0,
		180, 90
	]
	
	for idx in corners.size():
		var tile :Vector2 = tile_id + (corners[idx] * 2)
		nav.enable_nav_tile(0, tile, false)
		
		var w = wall_corner_scene.instance()
		w.material = Global.player_materials[p.color_idx]
		tile_map.get_tile_instance(tile).add_child(w)
		w.rotation_degrees.y = wall_corner_orientation[idx]
		
		if is_server:
			var guard_tower = preload("res://data/squad_data/static_guard_tower.tres").duplicate()
			guard_tower.network_id = 1
			guard_tower.player_id = p.player_id
			guard_tower.node_name = "tower_%s_%s" % [p.player_id, idx]
			guard_tower.current_tile = tile
			guard_tower.color_idx = p.color_idx
			guard_tower.team = p.team
			tower_datas.append(guard_tower)
		
		
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
	Global.change_scene("res://menus/battle_result/battle_result.tscn", true, 5 if Global.is_win else 6)
	
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
	
	ui.player_squads = player_squads
	ui.selected_squads = selected_squads
	
	add_child(ui)
	
	ui.scoreboard.init_scoreboard(players + bot_players)
	
	ui.squad_spawner.connect("on_squads_ready", self, "_on_squad_spawner_squads_ready")
	ui.route_button.connect("pressed", self, "_on_ui_route_button_pressed")
	
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
	if selected_squads.empty():
		return
		
	for i in selected_squads:
		i.attack_move = false
		
	_move_squad_to(tile_map.get_tile(player_spawn_points[current_player.player_id]), false)

func _on_selection_button_pressed(idx :int):
	# index 0 audio dont exist
	if idx > 0 and selected_squads.empty():
		unit_sound.stream = selection_group[idx].pick_random()
		unit_sound.play()
		
	ui.select_all_squad(idx)
	
########################################## squad  ############################################
var squads :Array = []
var squad_datas :Dictionary = {}

# current player
var player_squads :Array = []
var selected_squads :Array = []

# list of player got screw of their commander ded
var player_debuf :Array = [] 

func spawn_squads(squad_datas :Array):
	var list_bytes :Array = []
	for i in squad_datas:
		list_bytes.append(i.to_bytes())
		
	rpc("_spawn_squads", list_bytes)
	
func spawn_squad(squad_data :SquadData):
	rpc("_spawn_squad", squad_data.to_bytes())
	
remotesync func _spawn_squads(list_bytes :Array):
	for bytes in list_bytes:
		_spawn_squad(bytes)
		
remotesync func _spawn_squad(bytes :PoolByteArray):
	var data :SquadData = SquadData.new()
	data.from_bytes(bytes)
	
	var squad :BaseSquad = EntityIndex.squads[data.scene_idx].instance()
	squad.name = data.node_name
	squad.network_id = data.network_id
	squad.current_tile = data.current_tile
	
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

	# squad member
	squad.member_headgear = EntityIndex.head_armors[data.member_headgear_idx]
	squad.member_armor = EntityIndex.armors[data.member_armor_idx]
	squad.member_shield = EntityIndex.shields[data.member_shield_idx]
	squad.member_melee_weapon = EntityIndex.melee_weapons[data.member_melee_weapon_idx]
	squad.member_range_weapon = EntityIndex.range_weapons[data.member_range_weapon_idx]
	squad.member_material = Global.player_materials[data.color_idx]
	squad.member_hp = data.member_hp()
	squad.member_max_hp = data.member_hp()
	squad.heal_amount = data.heal_amount()
	squad.total_member = data.total_member
	squad.squad_role = data.squad_role
	squad.squad_icon = EntityIndex.squad_icon[data.icon_idx]
	
	# extra ui
	squad.enable_blood = setting.extra_effect
	squad.enable_squad_tile_indicator = setting.show_unit_tile
	squad.show_move_to_indicator = squad.player_id == current_player.player_id

	# for floating info
	squad.camera = movable_camera.camera
	squad.unit_indexing = tile_position_manager.get_unit_indexing()

	squad.connect("on_squad_taking_damage", self, "_on_squad_taking_damage")
	squad.connect("on_squad_member_dead", self, "_on_squad_member_dead", [data])
	squad.connect("on_squad_member_resurect", self, "_on_squad_member_resurect")
	#squad.connect("on_unit_spotted", self, "_on_unit_spotted")
	squad.connect("on_unit_clicked", self, "_on_unit_clicked")
	squad.connect("on_current_tile_updated", self, "_on_current_tile_updated")
	#squad.connect("on_finish_travel", self, "_on_finish_travel")
	squad.connect("on_squad_dead", self, "_on_squad_dead", [data])
	
	if squad is CavalrySquad:
		squad.charge_damage = data.charge_damage
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
		squad.nav_layer = 1 # build diffrent
		return
		
	squad_datas[squad] = data
	squads.append(squad)
	
	ui.add_squad_floating_info(squad, data, current_player)
	
	# use current spawn tile as reinfoce tile
	if player_reinfoce_tiles.has(squad.player_id):
		squad.reinfoce_tiles = player_reinfoce_tiles[squad.player_id]
	
	if squad.player_id == current_player.player_id:
		var is_commander :bool = (data.icon_idx == 6)
		player_squads.append(squad)
		ui.add_squad_card(squad, data)
		play_squad_spawn(is_commander)
	
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
		
func _on_squad_taking_damage(squad :BaseSquad, amount :int):
	if setting.show_feed:
		ui.log_event.add_log_damage(squad, amount)
	
func _on_squad_member_dead(squad :BaseSquad, member :SquadMember, data :SquadData):
	if setting.show_feed:
		ui.log_event.add_log_member_lost(squad, member)
		
	if player_ids.has(squad.player_id):
		ui.scoreboard.add_dead(player_ids[squad.player_id], data, 1)
	
	var from :BaseSquad = get_node_or_null(member.attacked_by)
	if not is_instance_valid(from):
		return
		
	if not player_ids.has(from.player_id) or not squad_datas.has(from):
		return
		
	var from_player :PlayerData = player_ids[from.player_id]
	var from_squad :SquadData = squad_datas[from]
	ui.scoreboard.add_kill(from_player, from_squad, 1)
	
	if from.team == squad.team:
		ui.scoreboard.add_friendly_fire(from_player, from_squad, 1)

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
			if randi() < 0.03: # 0.03% chance of pria solo
				ui_sound.stream = saya_akan_lawan
				
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
	var is_commander :bool = (data.icon_idx == 6)

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
			
		player_squads.erase(squad)
		ui.remove_squad_card(squad)
		
		play_squad_lost(is_commander)
		
	# confirm the kill was yours
	if squad.team != current_player.team:
		var attacked_by :BaseSquad = get_node_or_null(squad.attacked_by)
		if is_instance_valid(attacked_by):
			if attacked_by.player_id == current_player.player_id:
				play_squad_killed(is_commander)
				
	if squad.floating_info:
		squad.floating_info.visible = false
	
	yield(get_tree().create_timer(1),"timeout")
	squad.queue_free()
	
func _on_cav_charge(squad : CavalrySquad):
	if squad.player_id == current_player.player_id:
		unit_charged_impact(true)



































