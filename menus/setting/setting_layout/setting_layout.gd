extends Control

signal close

export var enable_setting_audio :bool = true
export var enable_setting_graphic :bool = true
export var enable_setting_profile :bool = true

onready var overlays = [
	$Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/audio_setting/overlay_audio,
	$Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/graphic_setting/overlay_graphic,
	$Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/profile_setting/overlay_profile
]

onready var right_panels = [
	$Control/Control/VBoxContainer/HBoxContainer/right_panel_audio,
	$Control/Control/VBoxContainer/HBoxContainer/right_panel_graphic,
	$Control/Control/VBoxContainer/HBoxContainer/right_panel_profile,
]

onready var audio_setting = $Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/audio_setting
onready var graphic_setting = $Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/graphic_setting
onready var profile_setting = $Control/Control/VBoxContainer/HBoxContainer/left_panel/VBoxContainer/profile_setting

func _ready():
	audio_setting.visible = enable_setting_audio
	graphic_setting.visible = enable_setting_graphic
	profile_setting.visible = enable_setting_profile
	
	_on_audio_setting_pressed()

func _hide_all():
	for i in overlays + right_panels:
		i.visible = false
	
func _on_back_pressed():
	Global.save_setting()
	emit_signal("close")

func _on_audio_setting_pressed():
	_hide_all()
	overlays[0].visible = true
	right_panels[0].visible = true
	
func _on_graphic_setting_pressed():
	_hide_all()
	overlays[1].visible = true
	right_panels[1].visible = true
	
func _on_profile_setting_pressed():
	_hide_all()
	overlays[2].visible = true
	right_panels[2].visible = true
