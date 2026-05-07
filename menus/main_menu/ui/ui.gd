extends Control

onready var list_map = $CanvasLayer/Control/VBoxContainer/list_map
onready var play = $CanvasLayer/Control/VBoxContainer/play

var map_selected_type :String = "PLAY" # PLAY or EDITOR

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkLobbyManager.connect("on_host_player_connected", self, "_on_host_player_connected")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	Global.hide_transition()
	
	play.visible = false
	list_map.visible = false
	
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
	
func _on_map_editor_pressed():
	play.visible = false
	list_map.visible = not list_map.visible
	map_selected_type = "EDITOR"
	list_map.set_title("Map to Edit")
	
func _on_list_map_close():
	list_map.visible = false

func _on_list_map_selected_map(manif :TileMapFileManifest):
	yield(Global.set_active_map(manif),"completed")
	
	if map_selected_type == "EDITOR":
		Global.change_scene("res://menus/map_editor/map_editor.tscn", true)
		
	elif map_selected_type == "PLAY":
		# test
		var player_data = Global.player_data
		player_data.player_id = Utils.create_unique_id()
		player_data.team = 1
		
		var config :NetworkServer = NetworkServer.new()
		NetworkLobbyManager.configuration = config
		NetworkLobbyManager.player_name = player_data.player_name
		NetworkLobbyManager.player_extra_data = player_data.to_dictionary()
		NetworkLobbyManager.init_lobby()
		
func _on_play_battle_pressed():
	list_map.visible = false
	play.visible = not play.visible
	
func _on_host_player_connected():
	Global.change_scene("res://menus/lobby/lobby.tscn", true)
	
func _on_host_pressed():
	list_map.visible = true
	play.visible = false
	map_selected_type = "PLAY"
	list_map.set_title("Map to Play")

func _on_join_pressed():
	# test
	var player_data = Global.player_data
	player_data.player_id = Utils.create_unique_id()
	player_data.team = 2
	
	Global.null_map_data()
	Global.change_scene("res://menus/join/join.tscn", false)
