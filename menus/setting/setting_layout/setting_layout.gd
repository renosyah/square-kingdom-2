extends Control

signal close

export var enable_setting_game :bool
export var enable_setting_audio :bool
export var enable_setting_graphic :bool
export var enable_setting_profile :bool

onready var option_buttons = [
	$Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/gameplay,
	$Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/audio_setting,
	$Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/graphic_setting,
	$Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/profile_setting
]

onready var overlays = [
	$Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/gameplay/overlay_gameplay,
	$Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/audio_setting/overlay_audio,
	$Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/graphic_setting/overlay_graphic,
	$Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/profile_setting/overlay_profile
]

onready var right_panels = [
	$Control/Control/VBoxContainer/HBoxContainer/ScrollContainer/VBoxContainer/right_panel_gameplay,
	$Control/Control/VBoxContainer/HBoxContainer/ScrollContainer/VBoxContainer/right_panel_audio,
	$Control/Control/VBoxContainer/HBoxContainer/ScrollContainer/VBoxContainer/right_panel_graphic,
	$Control/Control/VBoxContainer/HBoxContainer/ScrollContainer/VBoxContainer/right_panel_profile
]

onready var popup_choose_potrait = $popup_choose_potrait

func _ready():
	popup_choose_potrait.visible = false
	popup_choose_potrait.selected(Global.player_data.potrait_idx)
	
	right_panels[3].popup_choose_potrait = popup_choose_potrait
	popup_choose_potrait.connect("selected", right_panels[3], "_on_popup_choose_potrait_selected")
	
	option_buttons[0].visible = enable_setting_game
	option_buttons[1].visible = enable_setting_audio
	option_buttons[2].visible = enable_setting_graphic
	option_buttons[3].visible = enable_setting_profile
	
	
	_on_gameplay_pressed()
	
func _hide_all():
	for i in overlays + right_panels:
		i.visible = false
		
func _on_back_pressed():
	Global.save_player_data()
	Global.setting_updated()
	Global.save_setting()
	emit_signal("close")
	
func _on_gameplay_pressed():
	_hide_all()
	overlays[0].visible = true
	right_panels[0].visible = true
	
func _on_audio_setting_pressed():
	_hide_all()
	overlays[1].visible = true
	right_panels[1].visible = true
	
func _on_graphic_setting_pressed():
	_hide_all()
	overlays[2].visible = true
	right_panels[2].visible = true
	
func _on_profile_setting_pressed():
	_hide_all()
	overlays[3].visible = true
	right_panels[3].visible = true

func _on_popup_choose_potrait_close():
	popup_choose_potrait.visible = false
