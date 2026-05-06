extends Control

onready var list_map = $CanvasLayer/Control/list_map

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.hide_transition()

func _on_map_editor_pressed():
	list_map.visible = not list_map.visible

func _on_list_map_close():
	list_map.visible = false
