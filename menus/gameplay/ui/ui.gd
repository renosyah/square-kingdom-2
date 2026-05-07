extends Control
class_name GameplayUi

signal reset_camera
signal exit

onready var movable_camera_ui = $CanvasLayer/Control/movable_camera_ui
onready var movable_camera_minimap = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/minimap/movable_camera_minimap
onready var cam_rot_l = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/HBoxContainer/cam_rot_l
onready var cam_rot_r = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/HBoxContainer/cam_rot_r
onready var minimap = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/minimap
onready var dialog_menu = $CanvasLayer/Control/dialog_menu

func _ready():
	dialog_menu.visible = false

func setup_minimap(tile_map_data :TileMapFileData):
	minimap.load_data_map(tile_map_data)
	
func _on_cam_rot_reset_pressed():
	emit_signal("reset_camera")
	
func _on_back_pressed():
	dialog_menu.visible = true
	
func _on_dialog_menu_on_exit():
	emit_signal("exit")
