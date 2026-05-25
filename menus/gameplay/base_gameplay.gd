extends Node
class_name BaseGameplay

onready var is_server = NetworkLobbyManager.is_server()

func _ready():
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
	
	# usualy call this after doing some shady work
	# because we dont generate and prepare shit anymore
	# just tell everybody to join
	if NetworkLobbyManager.is_server():
		NetworkLobbyManager.set_host_ready()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	NetworkLobbyManager.leave()
	
func _on_leave():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", true)
	
func _on_all_player_ready():
	Global.hide_transition()
	

########################################## proccess  ############################################

func _process(delta):
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
	NetworkLobbyManager.set_ready()
	
	# this function only be called
	# if tile map is ready and setup properly
	setup_players_spawn_points()
	
########################################## players spawn  ############################################
onready var current_player :PlayerData = Global.current_player
onready var players :Array = Global.players # [PlayerData]

var player_spawn_points = []
var player_spawn_point :Vector2

func setup_players_spawn_points():
	var map_size :int = current_tile_map_manifest_data.map_size
	player_spawn_points = TileIndex.get_spawn_points(map_size, 3)
	
	for index in players.size():
		var p :PlayerData = players[index]
		if p.player_id == current_player.player_id:
			player_spawn_point = player_spawn_points[index]
			break
	
	var tile :TileMapData = tile_map.get_tile(player_spawn_point)
	if tile == null:
		return
	
	movable_camera.translation.x = tile.pos.x + 1
	movable_camera.translation.z = tile.pos.z + 1
	
########################################## camera  ############################################
var movable_camera :MovableCamera

func spawn_movable_camera():
	movable_camera = preload("res://assets/camera/movable_camera.tscn").instance()
	movable_camera.name = "movable_camera"
	add_child(movable_camera)
	movable_camera.translation = Vector3(0, 3, 0)
	movable_camera.rotation_degrees.y = 45
	
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
	var tile = tile_map.get_closes_tile(pos)
	_move_squad_to(tile)
	
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
	
	ui.minimap.load_data_map(current_tile_map_file_data)
	ui.route_button.connect("pressed", self, "_on_ui_route_button_pressed")
	
	var map_size :int = current_tile_map_manifest_data.map_size
	ui.movable_camera_ui.target = movable_camera
	ui.movable_camera_ui.camera_limit_bound = Vector3(map_size, 0, map_size)
	ui.movable_camera_ui.center_pos = tile_map.global_position
	ui.movable_camera_ui.detect_in_out = false
	
	ui.movable_camera_ui.move_speed = setting.camera_move_speed
	ui.movable_camera_ui.zoom_speed = setting.camera_zoom_speed
	
	ui.movable_camera_minimap.target = movable_camera
	ui.movable_camera_minimap.camera_limit_bound = Vector3(map_size, 0, map_size)
	ui.movable_camera_minimap.center_pos = tile_map.global_position
	ui.movable_camera_minimap.detect_in_out = false
	
func _on_setting_updated(d :SettingData):
	ui.movable_camera_ui.move_speed = d.camera_move_speed
	ui.movable_camera_ui.zoom_speed= d.camera_zoom_speed
	
func _on_ui_reset_camera():
	movable_camera.rotation_degrees.y = 45
	
func _on_ui_route_button_pressed():
	if selected_squads.empty():
		return
		
	for i in selected_squads:
		i.attack_move = false
		
	_move_squad_to(tile_map.get_tile(player_spawn_point))

########################################## squad  ############################################

var player_squads :Array = []
var selected_squads :Array
var squads :Array = []

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
	squad.speed = data.speed

	# squad data
	squad.member_scene = EntityIndex.members[data.member_scene_idx]
	squad.can_attack = data.can_attack
	squad.turning_speed = data.turning_speed
	squad.attack_speed = data.attack_speed
	squad.formation_density = data.formation_density
	squad.spotting_range = data.spotting_range

	# squad member
	squad.member_headgear = EntityIndex.equipment[data.member_headgear_idx]
	squad.member_armor = EntityIndex.equipment[data.member_armor_idx]
	squad.member_shield = EntityIndex.equipment[data.member_shield_idx]
	squad.member_melee_weapon = EntityIndex.weapons[data.member_melee_weapon_idx]
	squad.member_range_weapon = EntityIndex.weapons[data.member_range_weapon_idx]
	squad.member_material = Global.player_materials[data.color_idx]
	squad.member_hp = data.member_hp
	squad.member_max_hp = data.member_max_hp
	squad.heal_amount = data.heal_amount
	squad.member_alive = data.total_member
	squad.show_move_indicator = setting.show_unit_tile
	squad.squad_role = data.squad_role
	
	# for floating info
	squad.camera = movable_camera.camera

	#squad.connect("on_squad_taking_damage", self, "_on_squad_taking_damage")
	squad.connect("on_squad_member_dead", self, "_on_squad_member_dead")
	squad.connect("on_squad_member_resurect", self, "_on_squad_member_resurect")
	#squad.connect("on_unit_spotted", self, "_on_unit_spotted")
	squad.connect("on_unit_clicked", self, "_on_unit_clicked")
	squad.connect("on_current_tile_updated", self, "_on_current_tile_updated")
	#squad.connect("on_finish_travel", self, "_on_finish_travel")
	squad.connect("on_unit_dead", self, "_on_unit_dead", [data])
	
	if squad is CavalrySquad:
		squad.connect("on_cav_charge", self, "_on_cav_charge")
	
	squad.set_hidden(false)
	
	add_child(squad)
	
	squad.translation = data.pos
	squads.append(squad)
	_on_squad_spawned(squad, data)
	
func _on_squad_spawned(squad :BaseSquad, data :SquadData):
	tile_position_manager.add_to_position(squad, data.current_tile)
	
	if squad.player_id == current_player.player_id:
		# use current spawn tile as reinfoce tile
		squad.reinfoce_tiles = [player_spawn_point]
			
		player_squads.append(squad)
		ui.add_squad_card(squad, data)
		
	 # default layer
	squad.nav_layer = 0
	squad.nav = nav
	squad.unit_position = tile_position_manager.get_positions()
	squad.update_spotting()
	
	ui.minimap.add_object(squad, squad.color)
	ui.add_squad_floating_info(squad, data, current_player)
	
func _move_squad_to(tile :TileMapData):
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
		if setting.unselect_on_command:
			squad.click() # to unselect
			
		tap.tap(tile_map.get_tile(tile_id).pos, (1 if squad.attack_move else 0))
		idx += 1
		
func _on_squad_taking_damage(squad, amount):
	pass
	
func _on_squad_member_dead(squad :BaseSquad, member):
	pass
	
func _on_squad_member_resurect(squad :BaseSquad, member):
	pass
	
func _on_unit_spotted(squad):
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
			ui_sound.play()
			
		unit_attacking_response()
		
		var dup = selected_squads.duplicate() # must use dup pointer
		for s in dup:
			tap.tap(tile_map.get_tile(clicked_squad.current_tile).pos, 1)
			s.chase_enemy = clicked_squad
			s.chase_target()
			
			if setting.unselect_on_command:
				s.click() # to unselect
	
func _on_current_tile_updated(squad, from_id, to_id):
	tile_position_manager.update_position(squad, from_id, to_id)
	
func _on_finish_travel(squad, last_id, current_id):
	pass
	
func _on_unit_dead(squad :BaseSquad, data :SquadData):
	ui.minimap.remove_object(squad)
	
	tile_position_manager.remove_from_position(squad, squad.current_tile)
	squads.erase(squad)
	
	var is_commander :bool = (data.icon_idx == 6)
	
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
				
	squad.floating_info.visible = false
	yield(get_tree().create_timer(1),"timeout")
	squad.floating_info.queue_free()
	squad.queue_free()
	
func _on_cav_charge(squad):
	unit_charged_impact(true)



































