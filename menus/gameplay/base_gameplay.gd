extends Node
class_name BaseGameplay

onready var is_server = NetworkLobbyManager.is_server()
onready var current_player :PlayerData = Global.current_player
onready var players :Array = Global.players # [PlayerData]

func _ready():
	self.name = "gameplay"
	
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
			movable_camera.rotation_degrees.y -= 45 * delta
		elif ui.cam_rot_r.pressed:
			movable_camera.rotation_degrees.y += 45 * delta
			
		clickable_floor.translation = pos
		ui.minimap.rotation_rad = movable_camera.rotation.y
		ui.minimap.offset = Vector2(pos.x, pos.z) * 10
		
########################################## ambient sound  ############################################
var map_ambient :AudioStreamPlayer

var ap_ambient_pos :float = 0.0

func setup_ambient_audio():
	map_ambient = AudioStreamPlayer.new()
	map_ambient.volume_db = -12.0
	#grand_map_ambient.stream = preload("MUSIC.ogg")
	add_child(map_ambient)
	
########################################## position manager ############################################
var tile_position_manager :TilePositionManager

func setup_unit_position_manager():
	tile_position_manager = preload("res://addons/tile_position_manager/tile_position_manager.tscn").instance()
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

var player_spawn_points = []
var player_spawn_point :Vector2

func setup_players_spawn_points():
	var map_size :int = current_tile_map_manifest_data.map_size
	player_spawn_points = ReserveTile.get_spawn_points(map_size, 3)
	
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
	
########################################## UI  ############################################
var ui :GameplayUi

func setup_ui():
	ui = preload("res://menus/gameplay/ui/ui.tscn").instance()
	ui.name = "ui"
	ui.connect("reset_camera", self, "_on_ui_reset_camera")
	ui.connect("exit", self, "on_back_pressed")
	add_child(ui)
	
	ui.minimap.load_data_map(current_tile_map_file_data)
	
	var map_size :int = current_tile_map_manifest_data.map_size
	ui.movable_camera_ui.target = movable_camera
	ui.movable_camera_ui.camera_limit_bound = Vector3(map_size, 0, map_size)
	ui.movable_camera_ui.center_pos = tile_map.global_position
	ui.movable_camera_ui.detect_in_out = false
	
	ui.movable_camera_minimap.target = movable_camera
	ui.movable_camera_minimap.camera_limit_bound = Vector3(map_size, 0, map_size)
	ui.movable_camera_minimap.center_pos = tile_map.global_position
	ui.movable_camera_minimap.detect_in_out = false
	
func _on_ui_reset_camera():
	movable_camera.rotation_degrees.y = 45
	

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
	squad.team = data.team
	squad.color = Global.player_colors[data.color_idx]
	squad.speed = data.speed

	# squad data
	squad.member_scene = EntityIndex.members[data.member_scene_idx]
	squad.has_range_weapon = data.has_range_weapon
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
	
	squad.overlay_ui = ui.overlay_ui
	squad.camera = movable_camera.camera
	squad.squad_icon = EntityIndex.squad_icon[data.icon_idx]
	squad.selected_squads = selected_squads

	squad.connect("on_squad_taking_damage", self, "_on_squad_taking_damage")
	squad.connect("on_unit_spotted", self, "_on_unit_spotted")
	squad.connect("on_unit_clicked", self, "_on_unit_clicked")
	squad.connect("on_current_tile_updated", self, "_on_current_tile_updated")
	squad.connect("on_finish_travel", self, "_on_finish_travel")
	squad.connect("on_unit_dead", self, "_on_unit_dead")
	
	squad.set_hidden(false)
	
	add_child(squad)
	
	squad.translation = data.pos
	squads.append(squad)
	_on_squad_spawned(squad, data)
	
func _on_squad_spawned(squad :BaseSquad, data :SquadData):
	tile_position_manager.add_to_position(squad)
	
	if squad.player_id == current_player.player_id:
		player_squads.append(squad)
		ui.add_squad_card(squad, data, selected_squads)
		ui.sort_squad_holder()
		
	squad.nav = nav
	squad.unit_position = tile_position_manager.get_positions()
	squad.update_spotting()
	
	ui.minimap.add_object(squad, squad.color)
	
func _move_squad_to(tile :TileMapData):
	if selected_squads.empty():
		return
		
	var dup = selected_squads.duplicate() # must use dup pointer
	
	# formations
	var layer_id = dup[0].nav_layer
	var pos = [tile.id] + TileMapUtils.get_astar_adjacent_tile(
		nav.get_astar(layer_id), nav.get_navigation_id(layer_id, tile.id), 2
	) 
	
	var idx = 0
	for squad in dup:
		squad.move_to(pos[idx])
		squad.click() # to unselect
		idx += 1
	
func _on_squad_taking_damage(squad, amount):
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
	
	# if squad is enemy squad
	if clicked_squad.team != current_player.team:
		var dup = selected_squads.duplicate() # must use dup pointer
		for s in dup:
			s.chase_enemy = clicked_squad
			s.chase_target()
			s.click() # to unselect
	
func _on_current_tile_updated(squad, from_id, to_id):
	tile_position_manager.update_position(squad, from_id, to_id)
	
func _on_finish_travel(squad, last_id, current_id):
	pass
	
func _on_unit_dead(squad :BaseSquad):
	ui.minimap.remove_object(squad)
	tile_position_manager.remove_from_position(squad)
	squads.erase(squad)
	
	if squad.player_id == current_player.player_id:
		player_squads.erase(squad)
		ui.remove_squad_card(squad)
		ui.sort_squad_holder()
		
	yield(get_tree().create_timer(1),"timeout")
	squad.queue_free()






































