extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	Global.hide_transition()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_setting_layout_close()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_setting_layout_close()
			return
			
func _on_setting_layout_close():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", false)
