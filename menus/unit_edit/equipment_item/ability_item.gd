extends MarginContainer

signal selected

export var index :int
export var icon :StreamTexture
export var item_name :String
export var cooldown :String

onready var texture_rect = $MarginContainer/TextureRect
onready var equipment_name = $MarginContainer/VBoxContainer2/MarginContainer/MarginContainer/equipment_name
onready var overlay = $overlay
onready var cooldown_label = $MarginContainer/ColorRect/cooldown
onready var cooldown_indicator = $MarginContainer/ColorRect

func _ready():
	texture_rect.texture = icon
	equipment_name.text = item_name
	cooldown_label.text = cooldown
	cooldown_indicator.visible = not cooldown.empty()
	

func set_selected(v:bool):
	overlay.visible = v
	
func _on_Button_pressed():
	emit_signal("selected")
