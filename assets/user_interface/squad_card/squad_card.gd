extends MarginContainer
class_name SquadCard

var data:SquadData
var selected_squads :Array # refrences
var squad :BaseSquad # refrences

onready var _overlay = $overlay
onready var _bg = $bg
onready var _texture_rect = $MarginContainer/TextureRect

func _ready():
	_bg.color = squad.color
	_texture_rect.texture = EntityIndex.squad_potraits[data.potrait_idx]
	
	squad.connect("on_unit_clicked", self, "_on_unit_clicked")
	squad.connect("on_unit_dead", self, "_on_unit_dead")

func _on_unit_clicked(unit):
	_overlay.visible = squad in selected_squads

func _on_unit_dead(unit):
	queue_free()

func _on_Button_pressed():
	squad.click()
