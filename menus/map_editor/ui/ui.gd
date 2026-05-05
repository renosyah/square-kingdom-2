extends Control

onready var movable_camera_ui = $CanvasLayer/Control/movable_camera_ui
onready var movable_camera_minimap = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/minimap/movable_camera_minimap
onready var minimap = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/minimap
onready var cam_rot_l = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/HBoxContainer/cam_rot_l
onready var cam_rot_r = $CanvasLayer/Control/VBoxContainer/HBoxContainer2/MarginContainer/VBoxContainer/HBoxContainer/cam_rot_r
onready var random = $CanvasLayer/Control/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer4/HBoxContainer/random
onready var nav_toggle = $CanvasLayer/Control/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer4/HBoxContainer/nav_toggle

onready var minimap_size = minimap.rect_size

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.hide_transition()
	minimap.load_data_map(Global.current_tile_map_file_data)
	
func _process(delta):
	var cam :Spatial = movable_camera_ui.target
	if cam_rot_l.pressed:
		cam.rotation_degrees.y -= 45 * delta
		
	elif cam_rot_r.pressed:
		cam.rotation_degrees.y += 45 * delta
		
func _on_back_pressed():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", true)

func _on_cam_rot_reset_pressed():
	var cam :Spatial = movable_camera_ui.target
	cam.rotation_degrees.y = 45
