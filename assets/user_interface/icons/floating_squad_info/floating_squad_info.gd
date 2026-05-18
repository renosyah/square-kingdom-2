extends MarginContainer
class_name FloatingSquadInfo

export var icon :StreamTexture
export var color :Color
export var max_hp :int

onready var _hp_bar = $Control/hp_bar
onready var _color = $Control2/MarginContainer/MarginContainer/color
onready var _icon = $Control2/MarginContainer/MarginContainer/MarginContainer2/icon

func _ready():
	_icon.texture = icon
	_color.color = color
	_hp_bar.max_value = max_hp
	_hp_bar.value = max_hp
	
func update_bar(hp :int):
	_hp_bar.value = hp

