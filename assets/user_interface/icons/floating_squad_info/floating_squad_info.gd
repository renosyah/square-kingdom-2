extends MarginContainer
class_name FloatingSquadInfo

export var icon :StreamTexture
export var color :Color
export var max_hp :int
export var floating_hurt :bool

var selected_squads :Array # refrences
var squad :BaseTileUnit # refrences

onready var _hp_bar = $Control/hp_bar
onready var _color = $Control2/MarginContainer/MarginContainer/color
onready var _icon = $Control2/MarginContainer/MarginContainer/MarginContainer2/icon
onready var _overlay = $Control2/MarginContainer/overlay
onready var _hurt = $Control2/MarginContainer/hurt

func _ready():
	_icon.texture = icon
	_color.color = color
	_hp_bar.max_value = max_hp
	_hp_bar.value = max_hp
	set_process(floating_hurt)
	
	if floating_hurt:
		squad.connect("on_squad_taking_damage", self, "_on_squad_taking_damage")
		
	squad.connect("on_unit_clicked", self, "_on_unit_clicked")
	
func _process(delta):
	_hurt.color.a = lerp(_hurt.color.a, 0, 5 * delta)
	
func _on_squad_taking_damage(squad, amount):
	_hurt.color.a = 1
	
func update_bar(hp :int):
	_hp_bar.value = hp

func _on_unit_clicked(v):
	_overlay.visible = squad in selected_squads

func _on_Button_pressed():
	squad.click()
