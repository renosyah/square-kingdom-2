extends MarginContainer

signal selected_map(data)
signal close

const edit_map_button = preload("res://menus/list_maps/item/edit_map_button.tscn")

onready var grid_container = $VBoxContainer/HBoxContainer/ScrollContainer/GridContainer
onready var loaded_maps_edit_buttons = []

func _ready():
	load_map()
	
func load_map():
	Global.load_maps()
	_show_maps()
	
func _show_maps():
	for i in loaded_maps_edit_buttons:
		grid_container.remove_child(i)
		
	loaded_maps_edit_buttons.clear()
	
	for i in Global.current_tile_map_manifest_datas:
		var data :TileMapFileManifest = i
		var loaded_maps_edit_button = edit_map_button.instance()
		loaded_maps_edit_button.data = data
		loaded_maps_edit_button.connect("pressed", self, "_loaded_maps_edit_button_pressed")
		grid_container.add_child(loaded_maps_edit_button)
		grid_container.move_child(loaded_maps_edit_button, 0)
		loaded_maps_edit_buttons.append(loaded_maps_edit_button)
	
func _loaded_maps_edit_button_pressed(manif :TileMapFileManifest):
	emit_signal("selected_map", manif)
	
func _on_add_map_button_pressed():
	Global.empty_map_data()
	Global.change_scene("res://menus/map_editor/map_editor.tscn", true)

func _on_back_pressed():
	emit_signal("close")
