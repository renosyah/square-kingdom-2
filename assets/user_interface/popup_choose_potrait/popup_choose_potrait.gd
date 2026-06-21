extends Control

const item_scene = preload("res://assets/user_interface/popup_choose_potrait/item/item.tscn")

signal selected(idx)
signal close

onready var grid_container = $MarginContainer/VBoxContainer/MarginContainer3/ScrollContainer/GridContainer
var _prev_item

func _ready():
	for idx in EntityIndex.squad_potraits.size():
		var item = item_scene.instance()
		item.image = EntityIndex.squad_potraits[idx]
		item.connect("pressed", self, "_on_item_press", [idx, item])
		grid_container.add_child(item)
		
func _on_item_press(idx :int, item):
	emit_signal("selected",idx)
	
	if _prev_item:
		_prev_item.set_selected(false)
		
	item.set_selected(true)
	_prev_item = item
	
func _on_close_pressed():
	emit_signal("close")
