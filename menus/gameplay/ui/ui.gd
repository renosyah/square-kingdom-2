extends Control
class_name GameplayUi

signal reset_camera
signal exit

onready var overlay_ui = $CanvasLayer/Control/overlay_ui
onready var movable_camera_ui = $CanvasLayer/Control/movable_camera_ui
onready var movable_camera_minimap = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/minimap/movable_camera_minimap
onready var cam_rot_l = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/HBoxContainer/cam_rot_l
onready var cam_rot_r = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/HBoxContainer/cam_rot_r
onready var minimap = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/minimap
onready var dialog_menu = $CanvasLayer/Control/dialog_menu
onready var squad_holder = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/Control/VBoxContainer/HBoxContainer/squad_holder

func _ready():
	minimap.tile_scenes = TileIndex.tiles2d
	dialog_menu.visible = false

func add_squad_card(squad :BaseSquad, data :SquadData, selected_squads :Array):
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
	
func sort_squad_holder():
	var nodes = []
	for c in squad_holder.get_children():
		nodes.append(c)
		
	nodes.sort_custom(self, "_sort_by_order")
	
	for i in nodes.size():
		squad_holder.move_child(nodes[i], i)
		
func _sort_by_order(a, b):
	return a.data.squad_type < b.data.squad_type
	
func _on_cam_rot_reset_pressed():
	emit_signal("reset_camera")
	
func _on_back_pressed():
	dialog_menu.visible = true
	
func _on_dialog_menu_on_exit():
	emit_signal("exit")
