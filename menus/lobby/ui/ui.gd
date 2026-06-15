extends Control

const player_item_scene = preload("res://menus/lobby/player_item/player_item.tscn")

onready var player_holder = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer/players/HBoxContainer/VBoxContainer
onready var battle = $CanvasLayer/Control/Control/VBoxContainer/MarginContainer4/HBoxContainer/MarginContainer5/battle
onready var minimap = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/minimap
onready var map_name = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/map_name
onready var map_size = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/map_size
onready var sync_map = $sync_map
onready var label_loading_host = $CanvasLayer/Control/Control/VBoxContainer/MarginContainer4/HBoxContainer/MarginContainer4/Label_loading_host
onready var button_add_bot = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer/MarginContainer/button_add_bot
onready var confirm_popup = $CanvasLayer/confirm_popup
onready var movable_camera_minimap = $CanvasLayer/Control/Control/VBoxContainer/HBoxContainer/MarginContainer/VBoxContainer/MarginContainer/minimap/movable_camera_minimap
onready var army_editor = $CanvasLayer/army_editor
onready var army_editor_layout = $CanvasLayer/army_editor/army_editor_layout

onready var current_player :PlayerData = Global.current_player
onready var is_server = NetworkLobbyManager.is_server()
var idx_bg = [1, 2, 3, 4]

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
	confirm_popup.visible = false
	army_editor.visible = false
	
	current_player.player_network_id = NetworkLobbyManager.get_id()
	
	army_editor_layout.armies = Global.current_army
	army_editor_layout.squads = Global.current_squads
	army_editor_layout.display()
	
	if is_server:
		button_add_bot.visible = true
		label_loading_host.visible = false
		battle.visible = true
		
		load_map()
		
		sync_map.manifest = Global.current_tile_map_manifest_data
		sync_map.map_data = Global.current_tile_map_file_data
		
	else:
		button_add_bot.visible = false
		label_loading_host.visible = true
		battle.visible = false
		
		current_player.spawn_position = NetworkLobbyManager.get_players().size() - 1 # <- my index pos
		NetworkLobbyManager.update_player_extra_data(current_player.to_dictionary())
	
		if Global.current_tile_map_file_data == null:
			sync_map.request_map_data()
			return
			
		load_map()
	
func load_map():
	var manif = Global.current_tile_map_manifest_data
	var size = manif.map_size * 2 + 1
	map_name.text = "%s" % manif.map_name
	map_size.text = "(%s x %s)" % [size, size]
	minimap.load_data_map(Global.current_tile_map_file_data)
	
	movable_camera_minimap.camera_limit_bound = Vector3(manif.map_size, 0, manif.map_size)
	
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
	
func _on_sync_map_on_client_request_map(client_id):
	battle.disabled = true
	update_bot_player()
	
func _on_sync_map_on_map_received(client_id :int):
	if is_server:
		map_data_received(client_id)
		
	else:
		Global.current_tile_map_manifest_data = sync_map.manifest
		Global.current_tile_map_file_data = sync_map.map_data
		
		load_map()
		
func map_data_received(player_network_unique_id :int):
	Global.player_map_data_received.append(player_network_unique_id)
	
	var player_loading = false
	for i in player_holder.get_children():
		if i.player_network_unique_id == player_network_unique_id:
			i.set_loading(false)
		
		if i.is_loading():
			player_loading = true
			
	if NetworkLobbyManager.is_server():
		battle.disabled = player_loading
		
func _on_lobby_player_update(players :Array):
	var teams :Dictionary = {}
	
	for child in player_holder.get_children():
		player_holder.remove_child(child)
		child.queue_free()
		
	Global.players.clear()
	
	var player_loading = false
	for i in players:
		var player :NetworkPlayer = i
		
		var player_data :PlayerData = PlayerData.new()
		player_data.from_dictionary(player.extra)
		Global.players.append(player_data)
		
		var is_host :bool = player.player_network_unique_id == NetworkLobbyManager.host_id
		var has_map :bool = Global.player_map_data_received.has(player.player_network_unique_id)
		
		var item = player_item_scene.instance()
		item.player_network_unique_id = player.player_network_unique_id
		item.player = player_data
		item.can_kick = is_server and player.player_network_unique_id != 1
		item.can_change_team = current_player.player_id == player_data.player_id
		item.connect("team_change", self, "_on_team_change")
		item.connect("remove", self, "_on_player_removed", [player])
		
		teams[player_data.team] = true
		
		player_holder.add_child(item)
		
		if is_server:
			item.set_loading(not is_host and not has_map)
		
		if is_host:
			item.set_loading(false)
		
		
	for idx in Global.bot_players.size():
		var player_data :PlayerData = Global.bot_players[idx]
		
		var item = player_item_scene.instance()
		item.player_network_unique_id = player_data.player_network_id
		item.player = player_data
		item.can_kick = is_server
		item.can_change_team = is_server
		
		teams[player_data.team] = true
		
		if is_server:
			item.connect("team_change", self, "_on_bot_team_change", [idx])
			item.connect("remove", self, "_on_bot_player_removed", [idx])
			
		player_holder.add_child(item)
		
	battle.disabled = (teams.size() == 1)
	
func update_bot_player():
	var data = []
	for i in Global.bot_players:
		var p :PlayerData = i
		data.append(i.to_dictionary())
		
	rpc("_update_bot_player", data)
	
remotesync func _update_bot_player(data :Array):
	var players = NetworkLobbyManager.get_players()
	Global.bot_players.clear()
	
	var bot_slot = 4 - players.size()
	for i in data:
		if bot_slot > 0:
			var p = PlayerData.new()
			p.from_dictionary(i)
			p.spawn_position = players.size() + Global.bot_players.size()
			Global.bot_players.append(p)
			
		bot_slot -= 1
		
	if is_server:
		# dup
		var army_dup = {}
		for key in Global.bot_player_armies.keys():
			army_dup[key] = Global.bot_player_armies[key].duplicate()
			Global.bot_player_armies[key].clear()
			
		Global.bot_player_armies.clear()
		
		for i in Global.bot_players:
			var p : PlayerData = i
			Global.bot_player_armies[p.player_id] = army_dup[p.player_id].duplicate()
			
		# clean
		for key in army_dup.keys():
			army_dup[key].clear()
			
		army_dup.clear()
		
		var total_slot = 4 - (players.size() + Global.bot_players.size())
		button_add_bot.visible = total_slot > 0
		
	_on_lobby_player_update(players)
	
func _on_bot_team_change(team :int, idx :int):
	Global.bot_players[idx].team = team
	update_bot_player()
	
func _on_bot_player_removed(idx :int):
	var bot :PlayerData = Global.bot_players[idx]
	Global.bot_player_armies.erase(bot.player_id)
	Global.bot_players.remove(idx)
	update_bot_player()
	
func _on_team_change(t :int):
	current_player.team = t
	NetworkLobbyManager.update_player_extra_data(current_player.to_dictionary())
	
func _on_player_removed(player :NetworkPlayer):
	NetworkLobbyManager.kick_player(player.player_network_unique_id)
	
func on_back_pressed():
	confirm_popup.visible = true
	confirm_popup.show_popup("Leave", "Are you sure\nWant to leave lobby?")
	var r = yield(confirm_popup,"confirmed")
	confirm_popup.visible = false
	
	if r:
		Global.player_map_data_received.clear()
		NetworkLobbyManager.leave()
	
func _on_leave():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", true)
	
func _on_back_pressed():
	on_back_pressed()
	
func _on_host_ready():
	Global.change_scene("res://menus/gameplay/client/client.tscn", true, idx_bg.pick_random())
	
func _on_battle_pressed():
	Global.change_scene("res://menus/gameplay/host/host.tscn", true, idx_bg.pick_random())
	
func _on_button_add_bot_pressed():
	var results = Global.create_bot_player()
	var p: PlayerData = results[0]
	
	Global.bot_players.append(p)
	Global.bot_player_armies[p.player_id] = results[1]
	
	update_bot_player()

func _on_edit_army_pressed():
	army_editor.visible = true
	
func _on_army_editor_layout_close():
	army_editor.visible = false
	
func _on_army_editor_layout_save(temp_current_army):
	Global.current_army = temp_current_army
	Global.save_custom_squad()






















