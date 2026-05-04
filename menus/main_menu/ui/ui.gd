extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.hide_transition()

func _on_map_editor_pressed():
	Global.empty_map_data()
	Global.change_scene("res://menus/map_editor/map_editor.tscn", true)
