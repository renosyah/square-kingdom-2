extends Control
class_name GameplayUi

signal reset_camera
signal exit

const icon_unknown_mode = preload("res://assets/user_interface/icons/question.png")
const icon_normal_movement_mode = preload("res://assets/user_interface/icons/movement_mode.png")
const icon_attack_move_mode = preload("res://assets/user_interface/icons/attack_move_mode.png")

onready var ui_color :Color = Global.player_colors[Global.current_player.color_idx]
onready var overlay_ui = $CanvasLayer/Control/overlay_ui
onready var movable_camera_ui = $CanvasLayer/Control/movable_camera_ui
onready var movable_camera_minimap = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/minimap/movable_camera_minimap
onready var cam_rot_l = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/HBoxContainer/cam_rot_l
onready var cam_rot_r = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/HBoxContainer/cam_rot_r
onready var minimap = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/minimap
onready var dialog_menu = $CanvasLayer/Control/dialog_menu
onready var squad_holder = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/squad_holder
onready var squad_command_ui = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/squad_command
onready var selection_button = $CanvasLayer/Control/MarginContainer/VBoxContainer/selection_button
onready var movement_mode = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/squad_command/VBoxContainer/HBoxContainer/movement_mode
onready var route_button = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/squad_command/VBoxContainer/HBoxContainer2/route_button
onready var nine_patch_rect = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/squad_command/NinePatchRect

var current_movement_mode :int = 0 # 0:normal, 1:attack move
var player_squads :Array # refrences
var selected_squads :Array # refrences

func _ready():
	minimap.tile_scenes = TileIndex.tiles2d
	dialog_menu.visible = false
	movement_mode.icon = icon_normal_movement_mode
	squad_command_ui.visible = false
	
	minimap.set_color(ui_color)
	nine_patch_rect.modulate = ui_color
	
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
			
func _on_cam_rot_reset_pressed():
	emit_signal("reset_camera")
	
func _on_back_pressed():
	dialog_menu.visible = true
	
func _on_dialog_menu_on_exit():
	emit_signal("exit")

func _on_selection_button_pressed():
	var player_squad_size :int = player_squads.size()
	var selected_squad_size :int = selected_squads.size()
	
	# must use dup, because array can change its content
	var dup :Array = selected_squads.duplicate()
	
	# unselect all from selected_squads
	if selected_squad_size == player_squad_size:
		for i in dup:
			i.click()
			
	# select all that not in selected_squads
	elif player_squad_size != selected_squad_size:
		for i in player_squads:
			if not dup.has(i):
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

func _on_stop_button_pressed():
	if selected_squads.empty():
		return
		
	for i in selected_squads:
		var tile = i.current_tile
		i.move_to(tile)
		i.stop(false)
	


















