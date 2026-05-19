extends BaseGameplay

const squad_scenes = [
	preload("res://data/squad_data/axeman.tres"),
	preload("res://data/squad_data/peasant.tres"),
	preload("res://data/squad_data/spearman.tres"),
	preload("res://data/squad_data/swordman.tres"),
	preload("res://data/squad_data/archer.tres"),
	preload("res://data/squad_data/huscarls.tres")
]

func _on_all_player_ready():
	._on_all_player_ready()
	
	yield(get_tree().create_timer(1),"timeout")
	
	spawn_player_squad()
	
func spawn_player_squad():
	var datas = []
	var tiles = [player_spawn_point] + TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(), player_spawn_point, 1
	)
	for tile in tiles:
		var data :SquadData = squad_scenes.pick_random().duplicate()
		data.network_id = current_player.player_network_id
		data.player_id = current_player.player_id
		data.node_name = Utils.create_unique_id()
		data.current_tile = tile
		data.pos = tile_map.get_tile(tile).pos
		data.color_idx = current_player.color_idx
		data.team = current_player.team
		datas.append(data)
		
	spawn_squads(datas)

func _on_unit_dead(squad):
	._on_unit_dead(squad)
	
	if player_squads.size() < 1:
		spawn_player_squad()
