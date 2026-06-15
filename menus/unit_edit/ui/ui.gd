extends Control

onready var unit_editor_layout = $CanvasLayer/MarginContainer/unit_editor_layout

func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	Global.hide_transition()

	unit_editor_layout.player_color_idx = Global.player_data.color_idx
	unit_editor_layout.player_material = Global.player_materials[Global.player_data.color_idx]
	unit_editor_layout.camera_rotation_speed = Global.setting_data.camera_rotation_speed
	unit_editor_layout.current_squads = Global.current_squads
	unit_editor_layout.current_army = Global.current_army
	unit_editor_layout.display()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_unit_editor_layout_close()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_unit_editor_layout_close()
			return
			
func _on_unit_editor_layout_close():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", false)

func _on_unit_editor_layout_save_current_squads(squads, armies):
	Global.current_squads = squads
	Global.current_army = armies
	Global.save_custom_squad()
