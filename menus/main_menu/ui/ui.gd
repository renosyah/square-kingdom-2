extends Control

onready var list_map = $CanvasLayer/Control/VBoxContainer/Control/list_map
onready var play = $CanvasLayer/Control/VBoxContainer/Control/play

var map_selected_type :String = "PLAY" # PLAY or EDITOR

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkLobbyManager.connect("on_host_player_connected", self, "_on_host_player_connected")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	Global.hide_transition()
	
	hide_all()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	get_tree().quit()
	
func hide_all():
	play.visible = false
	list_map.visible = false
	
func _on_map_editor_pressed():
	hide_all()
	list_map.visible = true
	map_selected_type = "EDITOR"
	list_map.set_title("Map Editor")
	
func _on_list_map_close():
	list_map.visible = false

func _on_list_map_selected_map(manif :TileMapFileManifest):
	yield(Global.set_active_map(manif),"completed")
	
	if map_selected_type == "EDITOR":
		Global.change_scene("res://menus/map_editor/map_editor.tscn", true)
		
	elif map_selected_type == "PLAY":
		# unique new id each play
		var player_data = Global.player_data
		player_data.player_id = Utils.create_unique_id()
		Global.current_player = player_data
		Global.current_player.team = 1
		Global.current_player.spawn_position = 0
		
		var config :NetworkServer = NetworkServer.new()
		NetworkLobbyManager.configuration = config
		NetworkLobbyManager.player_name = player_data.player_name
		NetworkLobbyManager.player_extra_data = player_data.to_dictionary()
		NetworkLobbyManager.init_lobby()
		
func _on_play_battle_pressed():
	hide_all()
	play.visible = true
	
func _on_host_player_connected():
	Global.change_scene("res://menus/lobby/lobby.tscn", true)
	
func _on_host_pressed():
	hide_all()
	list_map.visible = true
	map_selected_type = "PLAY"
	list_map.set_title("Select map")

func _on_join_pressed():
	var player_data = Global.player_data
	player_data.player_id = Utils.create_unique_id()
	player_data.team = 2
	
	Global.null_map_data()
	Global.change_scene("res://menus/join/join.tscn", false)

func _on_setting_pressed():
	hide_all()
	Global.change_scene("res://menus/setting/setting.tscn", false)

func _on_list_map_new_map(nm):
	Global.current_tile_map_manifest_data.map_name = nm
	Global.change_scene("res://menus/map_editor/map_editor.tscn", true)

func _on_unit_editor_pressed():
	Global.change_scene("res://menus/army_edit/army_edit.tscn", false)

func _on_unit_pressed():
	Global.change_scene("res://menus/unit_edit/unit_edit.tscn", false)
