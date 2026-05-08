extends Control

signal on_continue
signal close

export var title :String
export var place_holder :String

onready var map_name_editor = $MarginContainer/VBoxContainer/map_name
onready var label = $MarginContainer/VBoxContainer/MarginContainer4/HBoxContainer2/Label

func show():
	label.text = title
	map_name_editor.placeholder_text = place_holder

func _on_close_popup_pressed():
	emit_signal("close")

func _on_continue_pressed():
	emit_signal("on_continue")
