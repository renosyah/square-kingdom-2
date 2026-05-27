extends Control
class_name GameplayUi

signal reset_camera
signal exit

const icon_unknown_mode = preload("res://assets/user_interface/icons/question.png")
const icon_normal_movement_mode = preload("res://assets/user_interface/icons/movement_mode.png")
const icon_attack_move_mode = preload("res://assets/user_interface/icons/attack_move_mode.png")
const icon_uncheck = preload("res://assets/user_interface/icons/uncheck.png")
const icon_lock = preload("res://assets/user_interface/icons/locked.png")

onready var setting :SettingData = Global.setting_data
onready var ui_color :Color = EntityIndex.player_colors[Global.current_player.color_idx]
onready var overlay_ui = $CanvasLayer/Control/overlay_ui
onready var movable_camera_ui = $CanvasLayer/Control/movable_camera_ui
onready var movable_camera_minimap = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/HBoxContainer/VBoxContainer/minimap/movable_camera_minimap
onready var cam_rot_l = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/cam_rot_l
onready var cam_rot_r = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/cam_rot_r
onready var minimap = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/HBoxContainer/VBoxContainer/minimap
onready var dialog_menu = $CanvasLayer/Control/dialog_menu
onready var squad_holder = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/squad_holder
onready var squad_command_ui = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/squad_command
onready var movement_mode = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/squad_command/VBoxContainer/HBoxContainer/movement_mode
onready var route_button = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/squad_command/VBoxContainer/HBoxContainer2/route_button
onready var nine_patch_rect = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/squad_command/NinePatchRect
onready var selection_mode = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/squad_command/VBoxContainer/HBoxContainer2/selection_mode
onready var control_ui = $CanvasLayer/Control/VBoxContainer/HBoxContainer2
onready var orbital_camera_ui = $CanvasLayer/Control/orbital_camera_ui
onready var menu_buttons = $CanvasLayer/Control/VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer
onready var cinematic = $CanvasLayer/Control/VBoxContainer/MarginContainer/HBoxContainer/cinematic
onready var log_event = $CanvasLayer/Control/log_event

onready var selection_button_all = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/HBoxContainer/VBoxContainer2/selection_button_all
onready var selection_button_cav = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/HBoxContainer/VBoxContainer2/selection_button_cav
onready var selection_button_inf = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/HBoxContainer/VBoxContainer2/selection_button_inf
onready var selection_button_rng = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/HBoxContainer/VBoxContainer2/selection_button_rng

var on_cinematic_mode :bool
var current_movement_mode :int = 0 # 0:normal, 1:attack move
var player_squads :Array # refrences
var selected_squads :Array # refrences

func _ready():
	orbital_camera_ui.visible = false
	
	minimap.tile_scenes = TileIndex.tiles2d
	dialog_menu.visible = false
	movement_mode.icon = icon_normal_movement_mode
	squad_command_ui.visible = false
	
	minimap.set_color(ui_color)
	nine_patch_rect.modulate = ui_color
	
	selection_mode.icon = icon_uncheck if setting.unselect_on_command else icon_lock
	
func _process(delta):
	var on_select = not selected_squads.empty()
	movable_camera_ui.detect_in_out = on_select
	cinematic.visible = on_select or (on_cinematic_mode and not on_select)
	
	if not on_select:
		return
		
	if is_instance_valid(selected_squads[0]):
		var pos = selected_squads[0].global_position
		orbital_camera_ui.orbit_pivot.translation = selected_squads[0].get_avg_member_pos(pos)
	
func selected_squads_updated():
	squad_command_ui.visible = not selected_squads.empty()
	_check_movement_mode()
	
func _check_movement_mode():
	if selected_squads.empty():
		return
	
	var mode_attack = 0
	var mode_normal = 0
	
	for i in selected_squads:
		if i.attack_move:
			mode_attack += 1
		else:
			mode_normal += 1
			
	if mode_normal > 0 and mode_attack == 0:
		movement_mode.icon = icon_normal_movement_mode
	elif mode_normal == 0 and mode_attack > 0:
		movement_mode.icon = icon_attack_move_mode
	else:
		movement_mode.icon = icon_unknown_mode
		
	
func add_squad_card(squad :BaseSquad, data :SquadData):
	var card = preload("res://assets/user_interface/squad_card/squad_card.tscn").instance()
	card.data = data
	card.squad = squad
	card.selected_squads = selected_squads
	squad_holder.add_child(card)
	
func remove_squad_card(squad :BaseSquad):
	for c in squad_holder.get_children():
		if c.squad == squad:
			squad_holder.remove_child(c)
			c.queue_free()
			break
			
func add_squad_floating_info(squad :BaseSquad, data :SquadData, p :PlayerData):
	var _floating_info :FloatingSquadInfo= preload("res://assets/user_interface/icons/floating_squad_info/floating_squad_info.tscn").instance()
	_floating_info.selected_squads = selected_squads
	_floating_info.squad = squad
	_floating_info.name = "info_%s" % name
	_floating_info.color = squad.color
	_floating_info.icon = EntityIndex.squad_icon[data.icon_idx]
	_floating_info.floating_hurt = squad.player_id == p.player_id
	_floating_info.total_member = data.total_member
	_floating_info.is_mounted = data.is_mounted
	overlay_ui.add_child(_floating_info)
	squad.floating_info = _floating_info
	
func select_all_squad(squad_role :int = 0):
	var player_squad_size :int = 0
	for i in player_squads:
		if i.squad_role == squad_role or squad_role == 0:
			 player_squad_size += 1
	
	var selected_squad_size :int = 0
	for i in selected_squads:
		if i.squad_role == squad_role or squad_role == 0:
			 selected_squad_size += 1
		
	# must use dup, because array can change its content
	var dup :Array = []
	for i in selected_squads:
		if i.squad_role == squad_role or squad_role == 0:
			 dup.append(i)
			
	# unselect all first
	# if want select spesific item
	var temp_dup = selected_squads.duplicate()
	if squad_role != 0 and not temp_dup.empty():
		for i in temp_dup:
			i.click() # unselect
			
		return
		
	# unselect all from selected_squads
	if selected_squad_size == player_squad_size:
		for i in dup:
			if (i.squad_role == squad_role or squad_role == 0):
				i.click()
			
	# select all that not in selected_squads
	elif player_squad_size != selected_squad_size:
		for i in player_squads:
			if dup.has(i):
				continue
				
			if (i.squad_role == squad_role or squad_role == 0):
				i.click()

func _on_movement_mode_pressed():
	if selected_squads.empty():
		return
		
	if current_movement_mode == 0:
		current_movement_mode = 1
		movement_mode.icon = icon_attack_move_mode
		for i in selected_squads:
			i.attack_move = true
			
	elif current_movement_mode == 1:
		current_movement_mode = 0
		movement_mode.icon = icon_normal_movement_mode
		for i in selected_squads:
			i.attack_move = false
			
func _on_cam_rot_reset_pressed():
	emit_signal("reset_camera")
	
func _on_back_pressed():
	dialog_menu.visible = true
	
func _on_dialog_menu_on_exit():
	emit_signal("exit")

func _on_stop_button_pressed():
	if selected_squads.empty():
		return
		
	for i in selected_squads:
		var tile = i.current_tile
		i.move_to(tile)
		i.stop(false)
	
func _on_selection_mode_pressed():
	setting.unselect_on_command = not setting.unselect_on_command
	selection_mode.icon = icon_uncheck if setting.unselect_on_command else icon_lock
	

func _on_cinematic_pressed():
	if movable_camera_ui.visible and not selected_squads.empty():
		on_cinematic_mode = true

		var y = selected_squads[0].rotation.y
		orbital_camera_ui.orbit_pivot.rotation.y = y
		
	else:
		on_cinematic_mode = false
		movable_camera_ui.target.translation.y = 3
		
	orbital_camera_ui.camera.current = on_cinematic_mode
	movable_camera_ui.target.camera.current = not on_cinematic_mode
	
	movable_camera_ui.visible = not on_cinematic_mode
	orbital_camera_ui.visible = on_cinematic_mode
	overlay_ui.visible = not on_cinematic_mode
	control_ui.visible = not on_cinematic_mode
	menu_buttons.visible = not on_cinematic_mode
	log_event.visible = not on_cinematic_mode































