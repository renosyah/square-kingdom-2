extends BaseGameplay

const squad_scenes = [
	preload("res://data/squad_data/axeman.tres"),
	preload("res://data/squad_data/peasant.tres"),
	preload("res://data/squad_data/spearman.tres"),
	preload("res://data/squad_data/swordman.tres"),
	preload("res://data/squad_data/archer.tres")
]

func _on_all_player_ready():
	._on_all_player_ready()
	
	yield(get_tree().create_timer(1),"timeout")
	
	spawn_player_squad()
	
func spawn_player_squad():
	var datas = []
	for i in 10:
		var data :SquadData = squad_scenes.pick_random().duplicate()
		data.network_id = 1
		data.player_id = player.player_id
		data.node_name = Utils.create_unique_id()
		data.current_tile = player_spawn_point
		data.pos = tile_map.get_tile(player_spawn_point).pos
		data.color_idx = player.color_idx
		data.team = 1
		datas.append(data)
		
	spawn_squads(datas)

func _on_unit_dead(squad):
	._on_unit_dead(squad)
	
	if player_squads.size() < 1:
		spawn_player_squad()
