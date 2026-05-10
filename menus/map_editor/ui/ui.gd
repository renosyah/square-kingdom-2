extends Control

signal on_nav_card_dropped(posv2, enable)
signal on_tile_card_dropped(posv2, tile_data)

onready var movable_camera_ui = $CanvasLayer/Control/movable_camera_ui
onready var movable_camera_minimap = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/minimap/movable_camera_minimap
onready var minimap = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/minimap
onready var cam_rot_l = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/HBoxContainer/cam_rot_l
onready var cam_rot_r = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/HBoxContainer/cam_rot_r
onready var random = $CanvasLayer/Control/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer4/HBoxContainer/random
onready var nav_toggle = $CanvasLayer/Control/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer4/HBoxContainer/nav_toggle
onready var dragable_item = $CanvasLayer/Control/dragable_item
onready var snack_bar = $CanvasLayer/Control/snack_bar
onready var list_map_bg = $CanvasLayer/Control/list_map_bg
onready var list_map = $CanvasLayer/Control/list_map_bg/list_map
onready var confirm_popup = $CanvasLayer/Control/confirm_popup
onready var map_name = $CanvasLayer/Control/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/map_name
onready var loading_screen = $CanvasLayer/loading_screen
onready var minimap_size = minimap.rect_size

onready var tile_cards = [
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/ground_card,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/mud_card,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/road_card, # for road, but no deployable road
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/sand_card,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/sea_card,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/tree_card,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/rock_card,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/nav_on_card,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/nav_off_card
]
onready var tile_cards_contents = [
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/ground_card/ground,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/mud_card/mud,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/road_card, # for road, but no deployable road
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/sand_card/sand,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/sea_card/sea,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/tree_card/tree,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/rock_card/rock,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/nav_on_card/nav_on,
	$CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/nav_off_card/nav_off
]

var nav_show :bool

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	list_map_bg.visible = false
	confirm_popup.visible = false
	
	minimap.tile_scenes = TileIndex.tiles2d
	minimap.load_data_map(Global.current_tile_map_file_data)
	
	map_name.text = Global.current_tile_map_manifest_data.map_name
	
	var idx = 0
	for card in tile_cards:
		card.connect("on_grab", self, "_on_card_on_grab", [tile_cards_contents[idx]])
		card.connect("on_draging", self, "_on_card_on_draging")
		card.connect("on_release", self, "_on_card_on_release", [idx])
		card.connect("on_cancel", self, "_on_card_on_cancel")
		idx += 1
		
func on_map_ready():
	loading_screen.visible = false
	Global.hide_transition()

func on_nav_toggle_pressed():
	nav_show = not nav_show
	if nav_show:
		snack_bar.text = "Navigation show!"
		snack_bar.show()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
			
func on_back_pressed():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", true)
	
func _process(delta):
	var cam :Spatial = movable_camera_ui.target
	if cam_rot_l.pressed:
		cam.rotation_degrees.y -= 45 * delta
		
	elif cam_rot_r.pressed:
		cam.rotation_degrees.y += 45 * delta
		
func _on_card_on_grab(card, pos, _child):
	dragable_item.visible = true
	dragable_item.rect_position = pos
	dragable_item.add_child(_child.duplicate())
	
func _on_card_on_draging(card, pos):
	dragable_item.rect_position = pos
	
func _on_card_on_release(card, pos, idx :int):
	dragable_item.visible = false
	var _child = dragable_item.get_child(0)
	dragable_item.remove_child(_child)
	_child.queue_free()
	
	if idx == 7:
		emit_signal("on_nav_card_dropped", pos, true)
		return
		
	if idx == 8:
		emit_signal("on_nav_card_dropped", pos, false)
		return
		
	var tile_data :TileMapData = TileMapData.new()
	tile_data.scene_idx = idx
	tile_data.rotation_idx = [0,1,2].pick_random()
	
	if idx == 4:
		tile_data.scene_idx = [4,5,6,7].pick_random()
		
	elif idx == 5:
		tile_data.scene_idx = [8,9,10].pick_random()
		
	emit_signal("on_tile_card_dropped", pos, tile_data)
	
func _on_card_on_cancel(card):
	dragable_item.visible = false
	var _child = dragable_item.get_child(0)
	dragable_item.remove_child(_child)
	_child.queue_free()
	
func _on_back_pressed():
	on_back_pressed()
	
func _on_cam_rot_reset_pressed():
	var cam :Spatial = movable_camera_ui.target
	cam.rotation_degrees.y = 45

func _on_list_map_selected_map(manif :TileMapFileManifest):
	yield(Global.set_active_map(manif),"completed")
	Global.change_scene("res://menus/map_editor/map_editor.tscn", true)

func _on_save_pressed():
	yield(Global.save_edited_map(minimap.get_viewport()), "completed")
	
	snack_bar.text = "Map Saved!"
	snack_bar.show()
	
	list_map.load_map()
	
func _on_load_pressed():
	list_map_bg.visible = true

func _on_list_map_close():
	list_map_bg.visible = false

func _on_delete_pressed():
	confirm_popup.show_popup("Delete Map", "Delete this map?")
	confirm_popup.visible = true
	
	var result = yield(confirm_popup, "confirmed")
	if result:
		Global.delete_map()
		Global.empty_map_data()
		Global.change_scene("res://menus/map_editor/map_editor.tscn", true)
		return
		
	confirm_popup.visible = false

func _on_list_map_new_map(nm):
	Global.current_tile_map_manifest_data.map_name = nm
	Global.change_scene("res://menus/map_editor/map_editor.tscn", true)



















