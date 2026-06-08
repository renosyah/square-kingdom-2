extends Control

signal close
signal create_new (map_name, size)

const uncheck = preload("res://assets/user_interface/icons/uncheck.png")
const check = preload("res://assets/user_interface/icons/check.png")

onready var map_size_button = {
	14:$MarginContainer/VBoxContainer/HBoxContainer3/small,
	16:$MarginContainer/VBoxContainer/HBoxContainer3/medium,
	18:$MarginContainer/VBoxContainer/HBoxContainer3/large,
	26:$MarginContainer/VBoxContainer/HBoxContainer3/huge
}
onready var map_name = $MarginContainer/VBoxContainer/HBoxContainer2/map_name

var selected_size :int = 18

func _ready():
	map_name.text = RandomNameGenerator.generate_name()
	map_size_button[selected_size].icon = check
	
	for key in map_size_button.keys():
		var btn :Button = map_size_button[key]
		btn.connect("pressed", self, "_map_size_button_press", [btn, key])

func _map_size_button_press(btn, v):
	selected_size = v
	
	for key in map_size_button.keys():
		var b :Button = map_size_button[key]
		b.icon = check if b == btn else uncheck
	
func _on_close_popup_pressed():
	emit_signal("close")
	
func _on_create_new_pressed():
	if map_name.text.empty():
		return
		
	emit_signal("create_new", map_name.text, selected_size)

func _on_button_random_name_pressed():
	map_name.text = RandomNameGenerator.generate_name()
