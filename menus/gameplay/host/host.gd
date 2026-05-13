extends BaseGameplay

onready var cavalry_squad = $cavalry_squad
onready var infantry_squad = $infantry_squad

func _on_tile_map_ready():
	._on_tile_map_ready()
	
	cavalry_squad.current_tile = Vector2(0, -1)
	
	cavalry_squad.nav = nav
	cavalry_squad.unit_position = tile_position_manager.get_positions()
	
	infantry_squad.nav = nav
	infantry_squad.unit_position = tile_position_manager.get_positions()
	
	infantry_squad.chase_enemy = cavalry_squad
	infantry_squad.chase_target()
	
	ui.minimap.add_object(cavalry_squad)
	ui.minimap.add_object(infantry_squad)
	
func _on_floor_clicked(pos :Vector3):
	._on_floor_clicked(pos)
	
	var tile = tile_map.get_closes_tile(pos)
	cavalry_squad.move_to(tile.id)
