extends MarginContainer

const max_value = 100
const switch_off = preload("res://assets/user_interface/icons/switch_off.png")
const switch_on = preload("res://assets/user_interface/icons/switch_on.png")

onready var music_volume_slider = $VBoxContainer/VBoxContainer/HBoxContainer/music_volume_slider
onready var sfx_volume_slider = $VBoxContainer/VBoxContainer/HBoxContainer2/sfx_volume_slider
onready var voice_volume_slider = $VBoxContainer/VBoxContainer/HBoxContainer3/voice_volume_slider

onready var music_volume_label = $VBoxContainer/VBoxContainer/HBoxContainer/music_volume_label
onready var sfx_volume_label = $VBoxContainer/VBoxContainer/HBoxContainer2/sfx_volume_label
onready var voice_volume_label = $VBoxContainer/VBoxContainer/HBoxContainer3/voice_volume_label
onready var mute_switch = $VBoxContainer/VBoxContainer/HBoxContainer4/mute_switch

onready var setting_data = Global.setting_data

func _ready():
	music_volume_slider.set_value_no_signal((setting_data.music * max_value))
	sfx_volume_slider.set_value_no_signal((setting_data.sfx * max_value))
	voice_volume_slider.set_value_no_signal((setting_data.voice * max_value))
	
	music_volume_label.text = "%s%s" % [(setting_data.music * max_value),"%"]
	sfx_volume_label.text = "%s%s" % [(setting_data.sfx * max_value),"%"]
	voice_volume_label.text = "%s%s" % [(setting_data.voice * max_value),"%"]
	
	mute_switch.icon = switch_on if setting_data.mute else switch_off
	
func _on_music_volume_slider_value_changed(value):
	music_volume_label.text = "%s%s" % [value,"%"]
	setting_data.music = clamp(0, float(value) / float(max_value), 1)
	Global.set_bus_volume(Global.bus_music, setting_data.music)

func _on_sfx_volume_slider_value_changed(value):
	sfx_volume_label.text = "%s%s" % [value,"%"]
	setting_data.sfx = clamp(0, float(value) / float(max_value), 1)
	Global.set_bus_volume(Global.bus_sfx, setting_data.sfx)

func _on_voice_volume_slider_value_changed(value):
	voice_volume_label.text = "%s%s" % [value,"%"]
	setting_data.voice = clamp(0, float(value) / float(max_value), 1)
	Global.set_bus_volume(Global.bus_voice, setting_data.voice)

func _on_mute_switch_pressed():
	setting_data.mute = not setting_data.mute
	_on_mute_switch_pressed_apply()
	
func _on_mute_switch_pressed_apply():
	mute_switch.icon = switch_on if setting_data.mute else switch_off
	Global.set_bus_mute(Global.bus_sfx, setting_data.mute)
	Global.set_bus_mute(Global.bus_music, setting_data.mute)
	Global.set_bus_mute(Global.bus_voice, setting_data.mute)

func _on_reset_button_pressed():
	var n = SettingData.new()
	
	music_volume_slider.set_value_no_signal(n.music * max_value)
	sfx_volume_slider.set_value_no_signal(n.sfx * max_value)
	voice_volume_slider.set_value_no_signal(n.voice * max_value)
	
	_on_music_volume_slider_value_changed(n.music * max_value)
	_on_sfx_volume_slider_value_changed(n.sfx * max_value)
	_on_voice_volume_slider_value_changed(n.voice * max_value)
	
	setting_data.mute = n.mute
	_on_mute_switch_pressed_apply()


