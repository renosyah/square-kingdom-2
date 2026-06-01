extends MarginContainer

const check = preload("res://assets/user_interface/icons/check.png")
const uncheck = preload("res://assets/user_interface/icons/uncheck.png")

onready var cam_speed_slider = $VBoxContainer/VBoxContainer/HBoxContainer3/cam_speed_slider
onready var zoom_speed_slider = $VBoxContainer/VBoxContainer/HBoxContainer2/zoom_speed_slider
onready var rot_speed_slider = $VBoxContainer/VBoxContainer/HBoxContainer/rot_speed_slider

onready var cam_speed_label = $VBoxContainer/VBoxContainer/HBoxContainer3/cam_speed_label
onready var zoom_speed_label = $VBoxContainer/VBoxContainer/HBoxContainer2/zoom_speed_label
onready var rot_speed_label = $VBoxContainer/VBoxContainer/HBoxContainer/rot_speed_label

onready var lock_command = $VBoxContainer/VBoxContainer/HBoxContainer6/HBoxContainer4/lock_command
onready var unit_tile = $VBoxContainer/VBoxContainer/HBoxContainer6/HBoxContainer5/unit_tile
onready var feed = $VBoxContainer/VBoxContainer/HBoxContainer6/HBoxContainer7/feed

onready var setting_data = Global.setting_data

func _ready():
	var s = _from_setting(setting_data.camera_move_speed, 0.008, 0.040)
	var z = _from_setting(setting_data.camera_zoom_speed, 0.01, 0.03)
	var r = _from_setting(setting_data.camera_rotation_speed, 20, 90)
	
	cam_speed_slider.set_value_no_signal(s)
	zoom_speed_slider.set_value_no_signal(z)
	rot_speed_slider.set_value_no_signal(r)
	
	cam_speed_label.text = "%s%s" % [s,"%"]
	zoom_speed_label.text = "%s%s" % [z,"%"]
	rot_speed_label.text = "%s%s" % [r,"%"]
	
	_apply_check()
	
func _from_setting(value, min_value, max_value) -> int:
	return int(((value - min_value) / (max_value - min_value)) * 100.0)
	
func _to_setting(value, min_value, max_value) -> float:
	return min_value + ((value / 100.0) * (max_value - min_value))

func _on_cam_speed_slider_value_changed(value):
	cam_speed_label.text = "%s%s" % [value,"%"]
	setting_data.camera_move_speed = _to_setting(value, 0.008, 0.040)

func _on_zoom_speed_slider_value_changed(value):
	zoom_speed_label.text = "%s%s" % [value,"%"]
	setting_data.camera_zoom_speed = _to_setting(value, 0.01, 0.03)

func _on_rot_speed_slider_value_changed(value):
	rot_speed_label.text = "%s%s" % [value,"%"]
	setting_data.camera_rotation_speed = _to_setting(value, 20, 90)

func _apply_check():
	lock_command.icon = check if setting_data.lock_command else uncheck
	unit_tile.icon = check if setting_data.show_unit_tile else uncheck
	feed.icon = check if setting_data.show_feed else uncheck
	
func _on_reset_button_pressed():
	var n = SettingData.new()
	
	var s = _from_setting(n.camera_move_speed, 0.008, 0.040)
	var z = _from_setting(n.camera_zoom_speed, 0.01, 0.03)
	var r = _from_setting(n.camera_rotation_speed, 20, 90)
	
	cam_speed_slider.set_value_no_signal(s)
	zoom_speed_slider.set_value_no_signal(z)
	rot_speed_slider.set_value_no_signal(r)
	
	_on_cam_speed_slider_value_changed(s)
	_on_zoom_speed_slider_value_changed(z)
	_on_rot_speed_slider_value_changed(r)
	
	setting_data.lock_command = n.lock_command
	setting_data.show_unit_tile = n.show_unit_tile
	setting_data.show_feed = n.show_feed
	
	_apply_check()
	
func _on_unit_tile_pressed():
	setting_data.show_unit_tile = not setting_data.show_unit_tile
	unit_tile.icon = check if setting_data.show_unit_tile else uncheck

func _on_feed_pressed():
	setting_data.show_feed = not setting_data.show_feed
	feed.icon = check if setting_data.show_feed else uncheck

func _on_lock_command_pressed():
	setting_data.lock_command = not setting_data.lock_command
	lock_command.icon = check if setting_data.lock_command else uncheck
