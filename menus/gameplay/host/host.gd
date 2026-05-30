extends BaseGameplay

const enemy_phases = [[0,0,0],[01,2,3],[1,2,3],[1,2,3,4,5,17],[0,1,2,3,4,5,6,7,8,12,16,17],[6,7,8,9,10,11,12,13,16,17,18]]

onready var bot_spawner_timer = $bot_spawner_timer

var bot_squads :Array
var wave_per_stage = 5
var current_wave = 1
var enemy_type_idx :int = 0

func _on_all_player_ready():
	._on_all_player_ready()
	
	yield(get_tree().create_timer(1),"timeout")
	
	spawn_squads(Global.prepare_army(current_player_spawn_point, tile_map))
	bot_spawner_timer.start()
	
func bot_attack_command(squad :BaseSquad, enemies :Array):
	if is_instance_valid(squad.enemy):
		return
		
	if squad is CavalrySquad:
		squad.chase_enemy = enemies.pick_random()
		squad.chase_target()
		
	else:
		squad.attack_move = true
		squad.move_to(enemies.pick_random().current_tile)
	
func _on_squad_spawned(squad :BaseSquad, data :SquadData):
	._on_squad_spawned(squad, data)
	
	if squad.player_id == "bot":
		bot_squads.append(squad)
		
func _on_squad_dead(squad, data):
	._on_squad_dead(squad, data)
	
	if squad.player_id == "bot":
		bot_squads.erase(squad)
		
	# progress
	if bot_squads.empty():
		current_wave += 1
		
		if current_wave == wave_per_stage:
			enemy_type_idx = int(clamp(enemy_type_idx + 1, 0, enemy_phases.size() - 1))
			current_wave = 0
		
func _on_bot_spawner_timer_timeout():
	bot_spawner_timer.start()
	
	var enemies = []
	for i in squads:
		if i.player_id != "bot":
			enemies.append(i)
			
	if not enemies.empty():
		for i in bot_squads:
			bot_attack_command(i, enemies)
			
	# limit harashment
	if bot_squads.size() >= Global.players.size():
		return
		
	var enemy_idx = enemy_phases[enemy_type_idx].pick_random()
	var data :SquadData = Global.custom_squads[enemy_idx].duplicate()
	data.network_id = 1
	data.player_id = "bot"
	data.node_name = Utils.create_unique_id()
	data.current_tile = Vector2.ZERO
	data.pos = Vector3.ZERO
	data.color_idx = 1
	data.team = -1
	spawn_squad(data)








