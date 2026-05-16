extends BaseGameplay

onready var infantry_squad = $infantry_squad
onready var infantry_squad_2 = $infantry_squad2

func _on_tile_map_ready():
	._on_tile_map_ready()
	
	infantry_squad.nav = nav
	infantry_squad_2.nav = nav
	
	infantry_squad_2.chase_enemy = infantry_squad
	infantry_squad_2.chase_target()
	
func _on_floor_clicked(pos :Vector3):
	._on_floor_clicked(pos)
	
	var tile = tile_map.get_closes_tile(pos)
	if infantry_squad_2.current_tile == tile.id:
		infantry_squad.chase_enemy = infantry_squad_2
		infantry_squad.chase_target()
		return
		
	infantry_squad.move_to(tile.id)
