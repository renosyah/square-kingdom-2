extends MarginContainer
class_name FloatingSquadInfo

export var icon :StreamTexture
export var color :Color
export var floating_hurt :bool
export var total_member :int
export var is_mounted :bool

var selected_squads :Array # refrences
var squad # refrences of BaseSquad

onready var _color = $Control2/MarginContainer/MarginContainer/color
onready var _icon = $Control2/MarginContainer/MarginContainer/MarginContainer2/icon
onready var _overlay = $Control2/MarginContainer/overlay
onready var _hurt = $Control2/MarginContainer/hurt
onready var _heal = $Control2/MarginContainer/heal
onready var _color2 = $Control2/MarginContainer/mounted/color
onready var _icon2 = $Control2/MarginContainer/mounted/MarginContainer2/icon

onready var _temp_green = $Control/temp_green
onready var _temp_red = $Control/temp_red
onready var _temp_grey = $Control/temp_grey

onready var _hp_bar_holder = $Control/MarginContainer/hp_bar_holder

onready var _green_color = $Control/temp_green.color
onready var _red_color = $Control/temp_red.color
onready var _mounted = $Control2/MarginContainer/mounted

var _member_bars :Dictionary = {} # {member:colorrect}

func _ready():
	visible = false
	_mounted.visible = is_mounted
	_icon.texture = icon
	_color.color = color
	
	squad.connect("on_squad_taking_damage", self, "_on_squad_taking_damage")
	squad.connect("on_squad_taking_heal", self, "_on_squad_taking_heal")
	squad.connect("on_squad_member_dead", self, "_on_squad_member_updated")
	squad.connect("on_squad_member_resurect", self, "_on_squad_member_updated")
	squad.connect("on_unit_clicked", self, "_on_unit_clicked")
	
	yield(squad,"on_squad_member_ready")
	_update_bar()
	visible = true
	
func _process(delta):
	if floating_hurt and visible:
		_hurt.color.a = lerp(_hurt.color.a, 0, 5 * delta)
		_heal.color.a = lerp(_heal.color.a, 0, 2 * delta)
	
func _on_squad_member_updated(_squad, _member):
	_update_bar()
	_update_bar_colors()
	
func _on_squad_taking_heal(_squad):
	if visible and floating_hurt:
		_heal.color.a = 1
		
	_update_bar_colors()
	
func _on_squad_taking_damage(_squad, amount):
	if visible and floating_hurt and amount > 0:
		_hurt.color.a = 1
		
	_update_bar_colors()
	
func _get_hp_color(hp :int, max_hp: int) -> Color:
	# prevent zero by devision
	if hp <= 0:
		return _red_color
		
	var ratio :float = float(hp) / float(max_hp)
	if ratio > 0.5:
		return Color.orange.linear_interpolate(
			_green_color,
			(ratio - 0.5) * 2.0
		)
		
	return _red_color.linear_interpolate(
		Color.orange,
		ratio * 2.0
	)
	
func _update_bar_colors():
	if _member_bars.empty():
		return
		
	var keys = _member_bars.keys().duplicate()
	keys.sort_custom(self, "_sort_by_hp")
	
	var values = []
	for key in keys:
		values.append(_member_bars[key])
	
	for idx in keys.size():
		var key = keys[idx]
		_member_bars[key].color = _get_hp_color(key.hp, key.max_hp)
		
	for val in values:
		_hp_bar_holder.move_child(val, values.find(val))
		
func _update_bar():
	_member_bars.clear()
	
	for i in _hp_bar_holder.get_children():
		_hp_bar_holder.remove_child(i)
		i.queue_free()
		
	var alive_member :Array = squad.get_members()
	
	for i in alive_member.size():
		var dup = _temp_green.duplicate()
		dup.visible = true
		_hp_bar_holder.add_child(dup)
		_member_bars[alive_member[i]] = dup
		
	for _i in (total_member - alive_member.size()):
		var dup = _temp_grey.duplicate()
		dup.visible = true
		_hp_bar_holder.add_child(dup)
	
func _sort_by_hp(a, b):
	return a.hp > b.hp
	
func _on_unit_clicked(_v):
	_overlay.visible = squad in selected_squads
	
	if is_mounted:
		_color2.color = Color("#ffffff") if _overlay.visible else Color("#000000")
		_icon2.modulate = Color("#ffffff") if not _overlay.visible else Color("#000000")
	
func _on_Button_pressed():
	squad.click()
