extends BaseGameplay

onready var test_squad = $test_squad
onready var test_squad_2 = $test_squad2

func _on_tile_map_ready():
	._on_tile_map_ready()
	
	test_squad.nav = nav
	test_squad.unit_position = tile_position_manager.get_positions()
	
	test_squad_2.nav = nav
	test_squad_2.unit_position = tile_position_manager.get_positions()
	
	test_squad_2.chase_enemy = test_squad
	test_squad_2.chase_target()
	
func _on_floor_clicked(pos :Vector3):
	._on_floor_clicked(pos)
	
	var tile = tile_map.get_closes_tile(pos)
	test_squad.move_to(tile.id)
