extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(_unload_preset_map(),"completed")
	Global.change_scene("res://menus/main_menu/main_menu.tscn", true)
	
func _unload_preset_map():
	yield(get_tree(), "idle_frame")
	var existing :PoolStringArray = Utils.get_all_resources("user://%s/" % Global.map_dir, ["manifest"])
	if not existing.empty():
		return
		
	yield(copy_preset_map(),"completed")
	
func copy_preset_map():
	var maps :Array = Utils.get_all_resources("res://data/preset_map/", ["png","manifest","mission","map"])
	for i in maps:
		var file_path :String = i
		Utils.copy_file_to_user(i, "user://%s/%s" % [Global.map_dir, file_path.get_file()])
		yield(get_tree(), "idle_frame")
		
