extends Control

signal on_exit

func _on_exit_pressed():
	emit_signal("on_exit")

func _on_close_pressed():
	visible = false
