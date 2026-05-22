extends Control

signal on_exit

onready var setting_layout = $setting_layout
onready var confirm_popup = $confirm_popup

func _ready():
	confirm_popup.visible = false
	setting_layout.visible = false

func _on_exit_pressed():
	confirm_popup.show_popup("Main Menu", "back to main menu?")
	
	confirm_popup.visible = true
	var result = yield(confirm_popup,"confirmed")
	confirm_popup.visible = false
	
	if result:
		emit_signal("on_exit")

func _on_close_pressed():
	visible = false

func _on_setting_pressed():
	setting_layout.visible = true

func _on_setting_layout_close():
	Global.setting_updated()
	Global.save_setting()
	setting_layout.visible = false
