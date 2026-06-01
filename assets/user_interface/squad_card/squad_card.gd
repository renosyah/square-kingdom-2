extends MarginContainer
class_name SquadCard

const color_red_trans = Color(0.537255,0,0,0.6)
const color_orange_trans = Color(1,0.647059,0,0.4)

var data:SquadData
var selected_squads :Array # refrences
var squad :BaseSquad # refrences

onready var _overlay = $overlay
onready var _bg = $bg
onready var _texture_rect = $MarginContainer/TextureRect
onready var _color = $MarginContainer/VBoxContainer/MarginContainer/MarginContainer/color
onready var _icon = $MarginContainer/VBoxContainer/MarginContainer/MarginContainer/MarginContainer2/icon
onready var _label = $MarginContainer/VBoxContainer2/ColorRect/Label
onready var _color2 = $MarginContainer/VBoxContainer/mounted/color
onready var _mounted = $MarginContainer/VBoxContainer/mounted
onready var _charge_amount = $MarginContainer/VBoxContainer2/charge_amount
onready var _hurt_color_stats = $MarginContainer/hurt_color_stats
onready var _button = $Button

onready var _heal = $heal
onready var _hurt = $hurt
onready var _not_on_screen = $not_on_screen

var _members :Array = []
var _total_hp :int = 0

func _ready():
	_not_on_screen.visible = false
	_mounted.visible = data.is_mounted
	_charge_amount.visible = data.is_mounted
	_bg.color = EntityIndex.player_colors[data.color_idx]
	_color.color = EntityIndex.player_colors[data.color_idx]
	_color2.color = EntityIndex.player_colors[data.color_idx]
	_texture_rect.texture = EntityIndex.squad_potraits[data.potrait_idx]
	_icon.texture = EntityIndex.squad_icon[data.icon_idx]
	_label.text = "%s" % data.total_member
	
	set_process(squad != null)
	_button.mouse_filter = MOUSE_FILTER_STOP if squad != null else MOUSE_FILTER_IGNORE
	
	if squad:
		_total_hp = squad.member_max_hp * squad.total_member
		squad.connect("on_unit_clicked", self, "_on_unit_clicked")
		squad.connect("on_squad_member_dead", self, "_on_squad_member_updated")
		squad.connect("on_squad_member_resurect", self, "_on_squad_member_updated")
		squad.connect("on_squad_taking_damage", self, "_on_squad_taking_damage")
		squad.connect("on_squad_taking_heal", self, "_on_squad_taking_heal")
		
		if data.is_mounted:
			squad.connect("on_cav_charge_buildup", self, "_on_cav_charge_buildup")
			squad.connect("on_cav_charge", self, "_on_cav_charge")
			
		var results = yield(squad,"on_squad_member_ready")
		_members = results[1]
		update_hurt_color_stats()
	
func update_hurt_color_stats():
	var current_total_hp :int = 0
	for i in _members:
		current_total_hp += i.hp
		
	_hurt_color_stats.color = _get_hp_color(current_total_hp,_total_hp)
	
func _get_hp_color(hp :int, max_hp: int) -> Color:
	# prevent zero by devision
	if hp <= 0:
		return color_red_trans
		
	var ratio :float = float(hp) / float(max_hp)
	if ratio > 0.5:
		return color_orange_trans.linear_interpolate(
			Color.transparent,
			(ratio - 0.5) * 2.0
		)
		
	return color_red_trans.linear_interpolate(
		color_orange_trans,
		ratio * 2.0
	)
	
func _process(delta):
	_not_on_screen.visible = not squad.visible
	_hurt.color.a = lerp(_hurt.color.a, 0, 5 * delta)
	_heal.color.a = lerp(_heal.color.a, 0, 2 * delta)
	
func _on_cav_charge_buildup(cav, amount):
	if amount <= 3:
		_charge_amount.text = ">".repeat(amount)
	
func _on_cav_charge(cav):
	_charge_amount.text = ""
	
func _on_squad_taking_heal(_squad):
	_heal.color.a = 1
	update_hurt_color_stats()
	
func _on_squad_taking_damage(_squad, amount):
	_hurt.color.a = 1
	update_hurt_color_stats()
	
func _on_unit_clicked(_unit):
	_overlay.visible = squad in selected_squads

func _on_squad_member_updated(_squad, _member):
	_label.text = "%s" % squad.member_alive
	update_hurt_color_stats()

func _on_Button_pressed():
	if squad:
		squad.click()
