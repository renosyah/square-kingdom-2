extends MarginContainer

export var simplified :bool = false

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
onready var _info_layout = $info_layout
onready var _spawn_time = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/HBoxContainer4/spawn_time

onready var _top_bar = $VBoxContainer/HBoxContainer2
onready var _pic = $VBoxContainer/HBoxContainer/MarginContainer3
onready var _icons = $VBoxContainer/HBoxContainer/VBoxContainer2
onready var _spawn = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/HBoxContainer4
onready var _name = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer
onready var _infos = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2

func _ready():
	_top_bar.visible = not simplified
	_pic.visible = not simplified
	_icons.visible = not simplified
	#_spawn.visible = not simplified
	_name.visible = not simplified
	_infos.alignment = BoxContainer.ALIGN_BEGIN if not simplified else BoxContainer.ALIGN_CENTER
	
	_info_layout.visible = false
	
func display_info(data :SquadData):
	_info_layout.visible = false
	_info_bg.color = EntityIndex.player_colors[data.color_idx]
	_info_potrait.texture = EntityIndex.squad_potraits[data.potrait_idx]
	_info_name.text = data.squad_name
	_info_description.text = data.description
	_info_icon_color.color = EntityIndex.player_colors[data.color_idx]
	_info_icon.texture = EntityIndex.squad_icon[data.icon_idx]
	_mounted.visible = data.is_mounted
	_info_icon_color2.color = EntityIndex.player_colors[data.color_idx]
	
	_hp.text = "%s | %s" % [data.member_hp(),data.heal_amount()]
	_attack.text = "%s | %s" % _get_attack_values(data)
	_speed.text = "%.2f" % data.speed()
	_spawn_time.text = Utils.format_time(data.spawn_time())
	
func _get_attack_values(data :SquadData) -> Array:
	var s = [0,0]
	var m :PackedScene = EntityIndex.melee_weapons[data.member_melee_weapon_idx]
	if m:
		var w :MeleeWeapon = m.instance()
		add_child(w)
		s[0] = calculate_dps(w.attack_damage, data.melee_attack_speed())
		w.queue_free()
		
	var r :PackedScene = EntityIndex.range_weapons[data.member_range_weapon_idx]
	if r:
		var w :RangeWeapon = r.instance()
		add_child(w)
		s[1] = calculate_dps(w.attack_damage * data.total_member, data.range_attack_speed()) 
		w.queue_free()
		
	# siege engine if not 0 or 1
	if not data.scene_idx in [0,1]:
		s[1] = data.siege_engine_attack_damage
		
	return s
	
func calculate_dps(damage: int, duration: float) -> int:
	if duration <= 0:
		return 0
		
	var v :float = float(damage) / duration
	
	return 1 if v > 0.0 and v < 1.0 else int(v)

func _on_info_pressed():
	_info_layout.visible = true

func _on_close_info_pressed():
	_info_layout.visible = false
