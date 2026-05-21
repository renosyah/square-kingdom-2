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

onready var _hurt = $hurt

func _ready():
	_bg.color = squad.color
	_color.color = squad.color
	_texture_rect.texture = EntityIndex.squad_potraits[data.potrait_idx]
	_icon.texture = EntityIndex.squad_icon[data.icon_idx]
	
	squad.connect("on_unit_clicked", self, "_on_unit_clicked")
	squad.connect("on_squad_member_dead", self, "_on_squad_member_dead")
	squad.connect("on_squad_taking_damage", self, "_on_squad_taking_damage")
	_label.text = "%s" % squad.member_alive
	
func _process(delta):
	_hurt.color.a = lerp(_hurt.color.a, 0, 5 * delta)
	
func _on_squad_taking_damage(_squad, _amount):
	_hurt.color.a = 1
	
func _on_unit_clicked(_unit):
	_overlay.visible = squad in selected_squads

func _on_squad_member_dead(_squad, _member):
	_label.text = "%s" % squad.member_alive

func _on_Button_pressed():
	squad.click()
