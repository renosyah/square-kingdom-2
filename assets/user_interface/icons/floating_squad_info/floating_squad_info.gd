extends MarginContainer
class_name FloatingSquadInfo

export var icon :StreamTexture
export var color :Color
export var max_hp :int

var selected_squads :Array # refrences
var squad :BaseTileUnit # refrences

onready var _hp_bar = $Control/hp_bar
onready var _color = $Control2/MarginContainer/MarginContainer/color
onready var _icon = $Control2/MarginContainer/MarginContainer/MarginContainer2/icon
onready var _overlay = $Control2/MarginContainer/overlay

func _ready():
	_icon.texture = icon
	_color.color = color
	_hp_bar.max_value = max_hp
	_hp_bar.value = max_hp
	
	squad.connect("on_unit_clicked", self, "_on_unit_clicked")
	
func update_bar(hp :int):
	_hp_bar.value = hp

func _on_unit_clicked(v):
	_overlay.visible = squad in selected_squads

func _on_Button_pressed():
	squad.click()
