extends MarginContainer

signal new_map(nm)
signal selected_map(data)
signal close

const edit_map_button = preload("res://menus/list_maps/item/edit_map_button.tscn")

onready var label = $VBoxContainer/MarginContainer/HBoxContainer2/Label
onready var new_map_name_popup = $new_map_name_popup
onready var grid_container = $VBoxContainer/HBoxContainer/ScrollContainer/GridContainer
onready var map_name = new_map_name_popup.map_name_editor

onready var loaded_maps_edit_buttons = []

func _ready():
	new_map_name_popup.visible = false
	load_map()
	
func load_map():
	Global.load_maps()
	_show_maps()
	
func set_title(v:String):
	label.text = v
	
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
	new_map_name_popup.title = "Map Name"
	new_map_name_popup.place_holder = Global.current_tile_map_manifest_data.map_name
	new_map_name_popup.show()
	new_map_name_popup.visible = true
	map_name.text = Global.current_tile_map_manifest_data.map_name
	
func _on_back_pressed():
	emit_signal("close")

func _on_new_map_name_popup_close():
	new_map_name_popup.visible = false

func _on_new_map_name_popup_on_continue():
	if map_name.text.empty():
		return
		
	emit_signal("new_map", map_name.text)
