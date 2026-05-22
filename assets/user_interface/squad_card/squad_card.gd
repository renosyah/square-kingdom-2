extends MarginContainer
class_name SquadCard

var data:SquadData
var selected_squads :Array # refrences
var squad :BaseSquad # refrences

onready var _overlay = $overlay
onready var _bg = $bg
onready var _texture_rect = $MarginContainer/TextureRect
onready var _color = $MarginContainer/MarginContainer/MarginContainer/color
onready var _icon = $MarginContainer/MarginContainer/MarginContainer/MarginContainer2/icon
onready var _label = $MarginContainer/ColorRect/Label

onready var _heal = $heal
onready var _hurt = $hurt
onready var _button = $Button

func _ready():
	_bg.color = Global.player_colors[data.color_idx]
	_color.color = Global.player_colors[data.color_idx]
	_texture_rect.texture = EntityIndex.squad_potraits[data.potrait_idx]
	_icon.texture = EntityIndex.squad_icon[data.icon_idx]
	_label.text = "%s" % data.total_member
	
	set_process(squad != null)
	_button.mouse_filter = MOUSE_FILTER_STOP if squad != null else MOUSE_FILTER_IGNORE
	
	if squad:
		squad.connect("on_unit_clicked", self, "_on_unit_clicked")
		squad.connect("on_squad_member_dead", self, "_on_squad_member_updated")
		squad.connect("on_squad_member_resurect", self, "_on_squad_member_updated")
		squad.connect("on_squad_taking_damage", self, "_on_squad_taking_damage")
		squad.connect("on_squad_taking_heal", self, "_on_squad_taking_heal")
		
func _process(delta):
	_hurt.color.a = lerp(_hurt.color.a, 0, 5 * delta)
	_heal.color.a = lerp(_heal.color.a, 0, 2 * delta)
	
func _on_squad_taking_heal(_squad):
	_heal.color.a = 1
	
func _on_squad_taking_damage(_squad, amount):
	_hurt.color.a = 1
	
func _on_unit_clicked(_unit):
	_overlay.visible = squad in selected_squads

func _on_squad_member_updated(_squad, _member):
	_label.text = "%s" % squad.member_alive

func _on_Button_pressed():
	if squad:
		squad.click()
