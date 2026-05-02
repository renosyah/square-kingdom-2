extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree().create_timer(0.8),"timeout")
	Global.change_scene("res://menus/main_menu/main_menu.tscn", true)
