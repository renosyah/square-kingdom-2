extends MarginContainer
class_name FloatingSquadInfo

export var icon :StreamTexture
export var color :Color
export var floating_hurt :bool
export var total_member :int

var selected_squads :Array # refrences
var squad # refrences of BaseSquad

onready var _color = $Control2/MarginContainer/MarginContainer/color
onready var _icon = $Control2/MarginContainer/MarginContainer/MarginContainer2/icon
onready var _overlay = $Control2/MarginContainer/overlay
onready var _hurt = $Control2/MarginContainer/hurt

onready var _temp_green = $Control/temp_green
onready var _temp_red = $Control/temp_red

onready var _hp_bar_holder = $Control/MarginContainer/hp_bar_holder

func _ready():
	_icon.texture = icon
	_color.color = color
	set_process(floating_hurt)
	
	_update_bar()
	
	if floating_hurt:
		squad.connect("on_squad_member_dead", self, "_on_squad_member_dead")
		squad.connect("on_squad_taking_damage", self, "_on_squad_taking_damage")
		
	squad.connect("on_unit_clicked", self, "_on_unit_clicked")
	
func _process(delta):
	_hurt.color.a = lerp(_hurt.color.a, 0, 5 * delta)
	
func _on_squad_member_dead(_squad, _member):
	_update_bar()
	
func _on_squad_taking_damage(_squad, _amount):
	_hurt.color.a = 1
	
func _update_bar():
	for i in _hp_bar_holder.get_children():
		_hp_bar_holder.remove_child(i)
		i.queue_free()
		
	var alive_member :Array = squad.get_members()
	
	for _i in alive_member.size():
		var dup = _temp_green.duplicate()
		dup.visible = true
		_hp_bar_holder.add_child(dup)
		
	for _i in (total_member - alive_member.size()):
		var dup = _temp_red.duplicate()
		dup.visible = true
		_hp_bar_holder.add_child(dup)
	
func _on_unit_clicked(_v):
	_overlay.visible = squad in selected_squads

func _on_Button_pressed():
	squad.click()
