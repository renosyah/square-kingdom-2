extends Control

const item_scene = preload("res://assets/user_interface/popup_choose_potrait/item/item.tscn")

signal selected(idx)
signal close

export var list :Array

onready var label = $MarginContainer/VBoxContainer/MarginContainer4/HBoxContainer/Label
onready var grid_container = $MarginContainer/VBoxContainer/MarginContainer3/ScrollContainer/GridContainer

var _prev_item

func display():
	for i in grid_container.get_children():
		grid_container.remove_child(i)
		i.queue_free()
	
	for idx in list.size():
		var item = item_scene.instance()
		item.image = list[idx]
		item.connect("pressed", self, "_on_item_press", [idx, item])
		grid_container.add_child(item)
		
func set_title(v:String):
	label.text = v
		
func selected(idx :int):
	var conditions = [
		list.empty(),
		idx < 0,
		idx > list.size() - 1
	]
	if conditions.has(true):
		return
		
	if _prev_item:
		_prev_item.set_selected(false)
		
	var item = grid_container.get_child(idx)
	item.set_selected(true)
	_prev_item = item
		
		
func _on_item_press(idx :int, item):
	if _prev_item == item:
		return
		
	emit_signal("selected",idx)
	selected(idx)
	
func _on_close_pressed():
	emit_signal("close")
