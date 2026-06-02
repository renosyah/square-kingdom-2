extends Control

signal confirmed(yes)

onready var _title = $MarginContainer/VBoxContainer/title
onready var _desc = $MarginContainer/VBoxContainer/desc

func show_popup(title :String, desc :String):
	_title.text = title
	_desc.text = desc

func _on_yes_pressed():
	emit_signal("confirmed", true)

func _on_no_pressed():
	emit_signal("confirmed", false)
