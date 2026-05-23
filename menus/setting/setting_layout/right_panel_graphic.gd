extends MarginContainer

const max_value = 100
const check = preload("res://assets/user_interface/icons/check.png")
const uncheck = preload("res://assets/user_interface/icons/uncheck.png")

onready var shadows_option = {
	0:$VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/disable,
	1:$VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/low,
	2:$VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/medium,
	3:$VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/high
}

onready var ts = $VBoxContainer/VBoxContainer/HBoxContainer2/HBoxContainer/ts
onready var fog = $VBoxContainer/VBoxContainer/HBoxContainer2/HBoxContainer2/fog

onready var setting_data = Global.setting_data
onready var light_label = $VBoxContainer/VBoxContainer/HBoxContainer3/light_label
onready var light_slider = $VBoxContainer/VBoxContainer/HBoxContainer3/light_slider

func _ready():
	_apply_setting()
	light_slider.set_value_no_signal((setting_data.light * max_value))
	
	for key in shadows_option.keys():
		shadows_option[key].connect("pressed", self, "_on_shadow_option_pressed", [key])
	
	for btn in [ts, fog]:
		btn.connect("pressed", self, "_on_check_option_pressed", [ btn ])
	
func _apply_setting():
	for key in shadows_option.keys():
		shadows_option[key].icon = check if key == setting_data.shadow_type else uncheck
		
	ts.icon = check if setting_data.enable_tilt_shift else uncheck
	fog.icon = check if setting_data.enable_fog else uncheck
	
	light_label.text = "%s%s" % [(setting_data.light * max_value),"%"]
	
func _on_check_option_pressed(btn):
	if btn == ts:
		setting_data.enable_tilt_shift = not setting_data.enable_tilt_shift
		
	elif btn == fog:
		setting_data.enable_fog = not setting_data.enable_fog
		
	_apply_setting()
	
func _on_shadow_option_pressed(v :int):
	setting_data.shadow_type = v
	_apply_setting()
	
func _on_light_slider_value_changed(value):
	light_label.text = "%s%s" % [value,"%"]
	setting_data.light = clamp(0, float(value) / float(max_value), 1)
	
func _on_reset_button_pressed():
	var n = SettingData.new()
	setting_data.shadow_type = n.shadow_type
	setting_data.enable_fog = n.enable_fog
	setting_data.enable_tilt_shift = n.enable_tilt_shift
	setting_data.light = n.light
	
	_apply_setting()




