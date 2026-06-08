extends MarginContainer

signal new_map(nm,size)
signal selected_map(data)
signal close

const edit_map_button = preload("res://menus/list_maps/item/edit_map_button.tscn")

onready var label = $VBoxContainer/MarginContainer/HBoxContainer2/Label
onready var new_map_popup = $new_map_popup
onready var grid_container = $VBoxContainer/HBoxContainer/ScrollContainer/GridContainer
onready var loaded_maps_edit_buttons = []

func _ready():
	new_map_popup.visible = false
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
	new_map_popup.visible = true

func _on_new_map_popup_close():
	new_map_popup.visible = false

func _on_new_map_popup_create_new(map_name, size):
	emit_signal("new_map", map_name, size)
