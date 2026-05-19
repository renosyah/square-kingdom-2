extends BaseGameplay

const squad_scenes = [
	preload("res://data/squad_data/axeman.tres"),
	preload("res://data/squad_data/peasant.tres"),
	preload("res://data/squad_data/spearman.tres"),
	preload("res://data/squad_data/swordman.tres"),
	preload("res://data/squad_data/archer.tres")
]

var bot_squads :Array

onready var bot_spawner_timer = $bot_spawner_timer

func _on_all_player_ready():
	._on_all_player_ready()
	
	yield(get_tree().create_timer(1),"timeout")
	
	spawn_player_squad()
	bot_spawner_timer.start()
	
func spawn_player_squad():
	var datas = []
	for i in 4:
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
	
func _on_squad_spawned(squad :BaseSquad, data :SquadData):
	._on_squad_spawned(squad, data)
	
	if squad.player_id == "bot":
		bot_squads.append(squad)
		
		squad.chase_enemy = player_squads.pick_random()
		squad.chase_target()

func _on_unit_dead(squad):
	._on_unit_dead(squad)
	
	if squad.player_id == "bot":
		bot_squads.erase(squad)
		
	if player_squads.size() < 1:
		spawn_player_squad()
	
func _on_bot_spawner_timer_timeout():
	bot_spawner_timer.start()
	
	if bot_squads.size() > 2:
		return
	
	var data :SquadData = squad_scenes.pick_random().duplicate()
	data.network_id = 1
	data.player_id = "bot"
	data.node_name = Utils.create_unique_id()
	data.current_tile = Vector2.ZERO
	data.pos = Vector3.ZERO
	data.color_idx = 0
	data.team = 2
	spawn_squad(data)








