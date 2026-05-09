extends Control

const player_item_scene = preload("res://menus/lobby/player_item/player_item.tscn")

onready var player_holder = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer/players/HBoxContainer/VBoxContainer
onready var battle = $CanvasLayer/Control/Control/VBoxContainer/MarginContainer4/HBoxContainer/battle
onready var minimap = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/minimap
onready var margin_container_4 = $CanvasLayer/Control/Control/VBoxContainer/MarginContainer4/HBoxContainer/MarginContainer4
onready var map_name = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/map_name
onready var map_size = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/map_size

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
	
	if NetworkLobbyManager.is_server():
		margin_container_4.visible = false
		battle.visible = true
		var manif = Global.current_tile_map_manifest_data
		var size = manif.map_size * 2 + 1
		map_name.text = "%s" % manif.map_name
		map_size.text = "(%s x %s)" % [size, size]
		
		_on_lobby_player_update(NetworkLobbyManager.get_players())
		minimap.load_data_map(Global.current_tile_map_file_data)
		
	else:
		margin_container_4.visible = true
		battle.visible = false
		rpc_id(NetworkLobbyManager.host_id, "_request_map_data", NetworkLobbyManager.get_id())
		
func _on_minimap_on_minimap_ready():
	Global.hide_transition()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
	
# for host
remote func _request_map_data(from_id :int):
	var _manifest :TileMapFileManifest = Global.current_tile_map_manifest_data
	var _map_data :TileMapFileData = Global.current_tile_map_file_data
	
	rpc_id(
		from_id, "_receive_map_data",
		var2bytes(_manifest.to_dictionary()),
		var2bytes(_map_data.to_dictionary())
	)
	
# for join player
remote func _receive_map_data(manifest: PoolByteArray, map_data: PoolByteArray):
	var _manifest :TileMapFileManifest = TileMapFileManifest.new()
	_manifest.from_dictionary(bytes2var(manifest))
	Global.current_tile_map_manifest_data = _manifest
	
	var _map_data :TileMapFileData = TileMapFileData.new()
	_map_data.from_dictionary(bytes2var(map_data))
	Global.current_tile_map_file_data = _map_data
	
	# tell host that you have receive map data
	minimap.load_data_map(Global.current_tile_map_file_data)
	map_name.text = "Map Name : %s" % _manifest.map_name
	map_size.text = "Size : %s" % _manifest.map_size
	
	rpc_id(NetworkLobbyManager.host_id ,"_map_data_received", NetworkLobbyManager.get_id())
	
# back to host
remote func _map_data_received(player_network_unique_id :int):
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
		
	var idx = 1
	for i in players:
		var player :NetworkPlayer = i
		
		var player_data :PlayerData = PlayerData.new()
		player_data.from_dictionary(player.extra)
		
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
	
func _on_host_ready():
	Global.change_scene("res://menus/gameplay/client/client.tscn", true)
	
func _on_leave():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", true)
	
func _on_back_pressed():
	on_back_pressed()

func _on_battle_pressed():
	Global.change_scene("res://menus/gameplay/host/host.tscn", true)














