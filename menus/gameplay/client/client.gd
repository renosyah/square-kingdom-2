extends BaseGameplay

onready var cavalry_squad = $cavalry_squad
onready var infantry_squad = $infantry_squad

func _on_tile_map_ready():
	._on_tile_map_ready()
	
	ui.minimap.add_object(cavalry_squad)
	ui.minimap.add_object(infantry_squad)
