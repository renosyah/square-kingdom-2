extends BaseGameplay

onready var infantry_squad = $infantry_squad
onready var infantry_squad_2 = $infantry_squad2
onready var infantry_squad_3 = $infantry_squad3

func _on_tile_map_ready():
	._on_tile_map_ready()
	
	var tile :TileMapData = tile_map.get_tile(player_spawn_point)
	if tile == null:
		return
		
	infantry_squad_2.current_tile = tile.id
	infantry_squad_2.translation = tile.pos
	infantry_squad_2.update_spotting()
	
	infantry_squad_3.current_tile = tile.id
	infantry_squad_3.translation = tile.pos
	infantry_squad_3.update_spotting()
	
	infantry_squad.nav = nav
	infantry_squad_2.nav = nav
	infantry_squad_3.nav = nav
	
	infantry_squad_2.chase_enemy = infantry_squad
	infantry_squad_2.chase_target()
	
	infantry_squad_3.chase_enemy = infantry_squad
	infantry_squad_3.chase_target()
	
func _on_floor_clicked(pos :Vector3):
	._on_floor_clicked(pos)
	
	var tile = tile_map.get_closes_tile(pos)
	var e = [infantry_squad_2, infantry_squad_3]
	for a in e:
		if a.current_tile == tile.id:
			infantry_squad.chase_enemy = a
			infantry_squad.chase_target()
			return
		
	infantry_squad.move_to(tile.id)
