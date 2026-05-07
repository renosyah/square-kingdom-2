extends BaseGameplay
onready var squad = $squad

func _on_grand_map_ready():
	._on_grand_map_ready()
	
	squad.nav = nav
	squad.nav_layer = 0
	
func _on_floor_clicked(pos :Vector3):
	._on_floor_clicked(pos)
	
	var tile = tile_map.get_closes_tile(pos)
	squad.move_to(tile.id)
