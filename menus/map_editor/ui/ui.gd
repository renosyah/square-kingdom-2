extends Control

onready var movable_camera_ui = $CanvasLayer/Control/VBoxContainer/movable_camera_ui

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.hide_transition()

func _on_back_pressed():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", true)
