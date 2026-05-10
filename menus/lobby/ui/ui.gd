extends Control

const player_item_scene = preload("res://menus/lobby/player_item/player_item.tscn")

onready var player_holder = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer/players/HBoxContainer/VBoxContainer
onready var battle = $CanvasLayer/Control/Control/VBoxContainer/MarginContainer4/HBoxContainer/MarginContainer5/battle
onready var minimap = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/minimap
onready var map_name = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/map_name
onready var map_size = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/map_size
onready var sync_map = $sync_map
onready var label_loading_host = $CanvasLayer/Control/Control/VBoxContainer/MarginContainer4/HBoxContainer/MarginContainer4/Label_loading_host

onready var is_server = NetworkLobbyManager.is_server()
var player_map_data_received :Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkLobbyManager.connect("lobby_player_update", self, "_on_lobby_player_update")
	NetworkLobbyManager.connect("on_host_disconnected", self, "_on_leave")
	NetworkLobbyManager.connect("on_leave", self, "_on_leave")
	NetworkLobbyManager.connect("on_kicked_by_host", self, "_on_leave")
	NetworkLobbyManager.connect("on_host_ready", self ,"_on_host_ready")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	minimap.tile_scenes = TileIndex.tiles2d
	
	if is_server:
		label_loading_host.visible = false
		battle.visible = true
		var manif = Global.current_tile_map_manifest_data
		var size = manif.map_size * 2 + 1
		map_name.text = "%s" % manif.map_name
		map_size.text = "(%s x %s)" % [size, size]
		
		sync_map.manifest = Global.current_tile_map_manifest_data
		sync_map.map_data = Global.current_tile_map_file_data
		minimap.load_data_map(Global.current_tile_map_file_data)
		
	else:
		label_loading_host.visible = true
		battle.visible = false
		sync_map.request_map_data()
		
func _on_minimap_on_minimap_ready():
	_on_lobby_player_update(NetworkLobbyManager.get_players())
	Global.hide_transition()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
	
func _on_sync_map_on_map_received(client_id :int):
	if is_server:
		map_data_received(client_id)
		
	else:
		Global.current_tile_map_manifest_data = sync_map.manifest
		Global.current_tile_map_file_data = sync_map.map_data
	
		minimap.load_data_map(sync_map.map_data)
		var size = sync_map.manifest.map_size * 2 + 1
		map_name.text = "%s" % sync_map.manifest.map_name
		map_size.text = "(%s x %s)" % [size, size]
		
func map_data_received(player_network_unique_id :int):
	var player_loading = false
	for i in player_holder.get_children():
		if i.player_network_unique_id == player_network_unique_id:
			player_map_data_received.append(i.id)
			i.set_loading(false)
		
		if i.is_loading():
			player_loading = true
			
	if NetworkLobbyManager.is_server():
		battle.disabled = player_loading
		
func _on_lobby_player_update(players :Array):
	for child in player_holder.get_children():
		player_holder.remove_child(child)
		child.queue_free()
		
	Global.players.clear()
		
	var idx = 1
	for i in players:
		var player :NetworkPlayer = i
		
		var player_data :PlayerData = PlayerData.new()
		player_data.from_dictionary(player.extra)
		Global.players.append(player_data)
		
		var is_host :bool = player.player_network_unique_id == NetworkLobbyManager.host_id
		var has_map :bool = player_map_data_received.has(player.player_network_unique_id)
		
		var item = player_item_scene.instance()
		item.player_network_unique_id = player.player_network_unique_id
		item.no = idx
		item.player = player_data
		player_holder.add_child(item)
		
		if NetworkLobbyManager.is_server():
			item.set_loading(not is_host and not has_map)
		
		if is_host:
			item.set_loading(false)
			
		idx += 1
		
	# make sure host dont initiate play
	# if player is more than 1 and not all ready
	if NetworkLobbyManager.is_server():
		battle.disabled = players.size() > 1
		
func on_back_pressed():
	NetworkLobbyManager.leave()
	
func _on_leave():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", true)
	
func _on_back_pressed():
	on_back_pressed()
	
func _on_host_ready():
	Global.change_scene("res://menus/gameplay/client/client.tscn", true)
	
func _on_battle_pressed():
	Global.change_scene("res://menus/gameplay/host/host.tscn", true)




















