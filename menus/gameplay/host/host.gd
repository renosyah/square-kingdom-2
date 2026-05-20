extends BaseGameplay

var bot_squads :Array

onready var bot_spawner_timer = $bot_spawner_timer

func _on_all_player_ready():
	._on_all_player_ready()
	
	yield(get_tree().create_timer(1),"timeout")
	
	spawn_squads(Global.prepare_army(player_spawn_point, tile_map))
	bot_spawner_timer.start()
	
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
	
	var data :SquadData = Global.template_squads.pick_random().duplicate()
	data.network_id = 1
	data.player_id = "bot"
	data.node_name = Utils.create_unique_id()
	data.current_tile = Vector2.ZERO
	data.pos = Vector3.ZERO
	data.color_idx = 0
	data.team = -1
	spawn_squad(data)








