extends Control

const player_item_scene = preload("res://menus/lobby/player_item/player_item.tscn")
onready var player_holder = $CanvasLayer/Control/Control/VBoxContainer/ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkLobbyManager.connect("lobby_player_update", self, "_on_lobby_player_update")
	NetworkLobbyManager.connect("on_host_disconnected", self, "_on_leave")
	NetworkLobbyManager.connect("on_leave", self, "_on_leave")
	NetworkLobbyManager.connect("on_kicked_by_host", self, "_on_leave")
	NetworkLobbyManager.connect("on_host_ready", self ,"_on_host_ready")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	if NetworkLobbyManager.is_server():
		_on_lobby_player_update(NetworkLobbyManager.get_players())
	else:
		request_map_data()
		
	Global.hide_transition()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
	
func request_map_data():
	pass
	
func host_play():
	Global.change_scene("res://menus/gameplay/host/host.tscn", true)
	
func _on_lobby_player_update(players :Array):
	for child in player_holder.get_children():
		player_holder.remove_child(child)
		child.queue_free()
		
	for i in players:
		var player :NetworkPlayer = i
		var item = player_item_scene.instance()
		item.player_network_unique_id = player.player_network_unique_id
		item.player_name = player.player_name
		player_holder.add_child(item)
		
func on_back_pressed():
	NetworkLobbyManager.leave()
	
func _on_host_ready():
	Global.change_scene("res://menus/gameplay/client/client.tscn", true)
	
func _on_leave():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", true)
	
func _on_back_pressed():
	on_back_pressed()











