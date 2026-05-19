extends BaseGameplay

const squad_scenes = [
	preload("res://data/squad_data/axeman.tres"),
	preload("res://data/squad_data/peasant.tres"),
	preload("res://data/squad_data/spearman.tres"),
	preload("res://data/squad_data/swordman.tres"),
	preload("res://data/squad_data/archer.tres"),
	preload("res://data/squad_data/huscarls.tres")
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
	
func bot_attack_command(squad :BaseSquad, enemies :Array):
	if squad.player_id != "bot":
		return
		
	if is_instance_valid(squad.enemy):
		return
		
	squad.attack_move = true
	squad.move_to(enemies.pick_random().current_tile)
		
func _on_squad_spawned(squad :BaseSquad, data :SquadData):
	._on_squad_spawned(squad, data)
	
	if squad.player_id == "bot":
		bot_squads.append(squad)
	
func _on_unit_dead(squad):
	._on_unit_dead(squad)
	
	if squad.player_id == "bot":
		bot_squads.erase(squad)
		
	if player_squads.size() < 1:
		spawn_player_squad()
	
func _on_bot_spawner_timer_timeout():
	bot_spawner_timer.start()
	
	var enemies = []
	for i in squads:
		if i.player_id != "bot":
			enemies.append(i)
			
	if not enemies.empty():
		for i in bot_squads:
			bot_attack_command(i, enemies)
	
	if bot_squads.size() > 2:
		return
	
	var data :SquadData = squad_scenes.pick_random().duplicate()
	data.network_id = 1
	data.player_id = "bot"
	data.node_name = Utils.create_unique_id()
	data.current_tile = Vector2.ZERO
	data.pos = Vector3.ZERO
	data.color_idx = 0
	data.team = -1
	spawn_squad(data)








