extends Control

onready var army_editor_layout = $CanvasLayer/army_editor_layout

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	set_process(false)
	
	army_editor_layout.armies = Global.current_army
	army_editor_layout.squads = Global.custom_squads
	army_editor_layout.display()
	
	Global.hide_transition()

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_army_editor_layout_close()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_army_editor_layout_close()
			return
			
func _on_army_editor_layout_close():
	Global.change_scene("res://menus/main_menu/main_menu.tscn", false)

func _on_army_editor_layout_save(temp_current_army):
	Global.current_army = temp_current_army
	Global.save_custom_squad()
