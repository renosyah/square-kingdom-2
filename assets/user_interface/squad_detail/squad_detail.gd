extends MarginContainer

onready var _info_bg = $VBoxContainer/HBoxContainer/MarginContainer3/squad_card/info_bg
onready var _info_potrait = $VBoxContainer/HBoxContainer/MarginContainer3/squad_card/MarginContainer/info_potrait
onready var _info_name = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/info_name
onready var _info_description = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/info_description
onready var _info_icon_color = $VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer6/MarginContainer/info_icon_color
onready var _info_icon = $VBoxContainer/HBoxContainer/VBoxContainer2/MarginContainer6/MarginContainer/MarginContainer2/info_icon
onready var _hp = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/HBoxContainer/hp
onready var _attack = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/HBoxContainer2/attack
onready var _speed = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/HBoxContainer3/speed
onready var _mounted = $VBoxContainer/HBoxContainer/VBoxContainer2/mounted
onready var _info_icon_color2 = $VBoxContainer/HBoxContainer/VBoxContainer2/mounted/MarginContainer/info_icon_color

func display_info(data :SquadData):
	_info_bg.color = EntityIndex.player_colors[data.color_idx]
	_info_potrait.texture = EntityIndex.squad_potraits[data.potrait_idx]
	_info_name.text = data.squad_name
	_info_description.text = data.description
	_info_icon_color.color = EntityIndex.player_colors[data.color_idx]
	_info_icon.texture = EntityIndex.squad_icon[data.icon_idx]
	_hp.text = "%s | %s" % [data.member_max_hp,data.heal_amount]
	_attack.text = "%s | %s" % _get_attack_values(data)
	_speed.text = "%s" % data.speed
	_mounted.visible = data.is_mounted
	_info_icon_color2.color = EntityIndex.player_colors[data.color_idx]
	
func _get_attack_values(data :SquadData) -> Array:
	var s = [0,0]
	var m :PackedScene = EntityIndex.weapons[data.member_melee_weapon_idx]
	if m:
		var w :MeleeWeapon = m.instance()
		add_child(w)
		s[0] = w.attack_damage
		w.queue_free()
		
	var r :PackedScene = EntityIndex.weapons[data.member_range_weapon_idx]
	if r:
		var w :RangeWeapon = r.instance()
		add_child(w)
		s[1] = w.attack_damage
		w.queue_free()
		
	return s











