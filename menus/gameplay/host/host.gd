extends BaseGameplay

const enemy_phases = [[0,0,0],[01,2,3],[1,2,3],[1,2,3,4,5,17],[0,1,2,3,4,5,6,7,8,12,16,17],[6,7,8,9,10,11,12,13,16,17,18]]

onready var bot_harasment_spawner_timer = $bot_harasment_spawner_timer
onready var bot_action_timer = $bot_action_timer

var bot_harasment_squads :Array
var wave_per_stage = 5
var current_wave = 1
var enemy_type_idx :int = 0

var bot_player_ids :Array
var bot_squads :Dictionary = {} # {bot_id:[BaseSquad]}

func _ready():
	for i in bot_players:
		bot_player_ids.append(i.player_id)

func _on_all_player_ready():
	._on_all_player_ready()
	
	yield(get_tree().create_timer(1),"timeout")
	
	spawn_squads(Global.prepare_army(
		Global.current_army, player_spawn_points[current_player.player_id], current_player, tile_map
	))
	
	for p in bot_players:
		var armies = Global.prepare_army(
			Global.bot_player_armies[p.player_id],
			player_spawn_points[p.player_id],
			p, tile_map, true
		)
		for s in armies:
			_spawn_squad(s)

	bot_harasment_spawner_timer.start()
	bot_action_timer.start()
	
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
	
	if squad.player_id in bot_player_ids:
		if not bot_squads.has(squad.player_id):
			bot_squads[squad.player_id] = []
		
		bot_squads[squad.player_id].append(squad)
	
	if squad.player_id == "bot_harasment":
		bot_harasment_squads.append(squad)
		
func _on_squad_dead(squad, data):
	._on_squad_dead(squad, data)
	
	if squad.player_id in bot_player_ids:
		bot_squads[squad.player_id].erase(squad)
	
	if squad.player_id == "bot_harasment":
		bot_harasment_squads.erase(squad)
		
	# progress
	if bot_harasment_squads.empty():
		current_wave += 1
		
		if current_wave == wave_per_stage:
			enemy_type_idx = int(clamp(enemy_type_idx + 1, 0, enemy_phases.size() - 1))
			current_wave = 0
		
func _on_bot_spawner_timer_timeout():
	bot_harasment_spawner_timer.start()
	
	var enemies = []
	for i in squads:
		if i.team != -1:
			enemies.append(i)
			
	if not enemies.empty() and not bot_harasment_squads.empty():
		var i = bot_harasment_squads.pick_random()
		if not i.is_moving():
			bot_attack_command(i, enemies)
			
	# limit harashment
	if bot_harasment_squads.size() >= Global.players.size():
		return
		
	var enemy_idx = enemy_phases[enemy_type_idx].pick_random()
	var data :SquadData = Global.custom_squads[enemy_idx].duplicate()
	data.network_id = 1
	data.player_id = "bot_harasment"
	data.node_name = Utils.create_unique_id()
	data.current_tile = Vector2.ZERO
	data.pos = Vector3.ZERO
	data.color_idx = 1
	data.team = -1
	spawn_squad(data)

func _on_bot_action_timer_timeout():
	bot_action_timer.start()
	
	if bot_squads.empty():
		return
	
	var id = bot_player_ids.pick_random()
	if bot_squads[id].empty():
		return
		
	var enemies = []
	for i in squads:
		if i.team != -1:
			enemies.append(i)
			
	if not enemies.empty() and not bot_squads[id].empty():
		var i = bot_squads[id].pick_random()
		if not i.is_moving():
			bot_attack_command(i, enemies)
	














