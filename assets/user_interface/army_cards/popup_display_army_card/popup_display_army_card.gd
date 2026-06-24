extends Control

const item_scene = preload("res://assets/user_interface/army_cards/popup_display_army_card/item/item.tscn")

signal close

export var army_cards :Array

onready var grid_container = $MarginContainer/VBoxContainer/MarginContainer3/ScrollContainer/GridContainer

func _ready():
	display()
	
func display():
	for i in grid_container.get_children():
		grid_container.remove_child(i)
		i.queue_free()
		
	for i in army_cards:
		var c :ArmyCardData = i
		var item = item_scene.instance()
		item.card = c
		grid_container.add_child(item)


func _on_close_pressed():
	emit_signal("close")
