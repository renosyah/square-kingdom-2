extends Node
class_name BaseGameplay

onready var is_server = NetworkLobbyManager.is_server()
onready var player :PlayerData = Global.player_data

func _ready():
	self.name = "gameplay"
	
	NetworkLobbyManager.connect("all_player_ready", self, "_on_all_player_ready")
	NetworkLobbyManager.connect("on_host_disconnected", self, "_on_leave")
	NetworkLobbyManager.connect("on_leave", self, "_on_leave")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
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
