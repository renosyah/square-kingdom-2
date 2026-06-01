extends BaseGameplay

const bandit_troops = [[0,0,1],[0,1,2,3],[1,2,3],[1,2,3,4,5,17],[0,1,2,3,4,5,6,7,8,12,16,17],[6,7,8,9,10,11,12,13,16,17,18]]

onready var bot_bandit_spawner_timer = $bot_bandit_spawner_timer
onready var bot_action_timer = $bot_action_timer
onready var bot_squad_spawner = $bot_squad_spawner

onready var spawn_pos = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions())

var bot_bandit_squads :Array
var wave_per_stage = 5
var current_wave = 1
var enemy_type_idx :int = 0
var bandit_killed :int = 0
var killed_treshold :int = 5

var bot_player_ids :Array
var bot_squads :Dictionary = {} # {bot_id:[BaseSquad]}

func _ready():
	for i in bot_players:
		bot_player_ids.append(i.player_id)

func _on_all_player_ready():
	._on_all_player_ready()
	
	yield(get_tree().create_timer(1),"timeout")
	var _squads = []
	
	# spawn host squad and all bots squads
	for p in bot_players:
		_squads.append_array(Global.prepare_army(
			Global.bot_player_armies[p.player_id],
			player_spawn_points[p.player_id], p
		))
		
	bot_squad_spawner.add_spawn_queue(_squads)
	
	bot_bandit_spawner_timer.start()
	bot_action_timer.start()
	
func _on_bot_squad_spawner_on_squads_ready(datas):
	spawn_squads(datas)
	
func bot_attack_command(squad :BaseSquad, enemy :BaseSquad):
	if is_instance_valid(squad.enemy):
		return
		
	if squad is CavalrySquad:
		squad.chase_enemy = enemy
		squad.chase_target()
		
	else:
		squad.attack_move = true
		squad.move_to(enemy.current_tile)
	
func _on_squad_spawned(squad :BaseSquad, data :SquadData):
	._on_squad_spawned(squad, data)
	
	if squad is GuardTowerSquad:
		return
		
	if squad.player_id in bot_player_ids:
		if not bot_squads.has(squad.player_id):
			bot_squads[squad.player_id] = []
		
		bot_squads[squad.player_id].append(squad)
		
	if squad.player_id == bot_bandit.player_id:
		bot_bandit_squads.append(squad)
		
func _on_squad_dead(squad, data):
	._on_squad_dead(squad, data)
	
	if squad is GuardTowerSquad:
		return
	
	if squad.player_id in bot_player_ids:
		bot_squads[squad.player_id].erase(squad)
	
	if squad.player_id == bot_bandit.player_id:
		bot_bandit_squads.erase(squad)
		bandit_killed += 1
		
	# up progress, facing more formidable bandit
	if bandit_killed > killed_treshold:
		bandit_killed = 0
		current_wave += 1
		
		if current_wave == wave_per_stage:
			enemy_type_idx = int(clamp(enemy_type_idx + 1, 0, bandit_troops.size() - 1))
			current_wave = 0
		
func _on_squad_member_dead(squad :BaseSquad, member :SquadMember, data :SquadData):
	._on_squad_member_dead(squad, member, data)
	
	if squad is GuardTowerSquad:
		return
		
	var conditions = [
		randf() < 0.6,
		squad.member_alive > 2,
	]
	
	var is_bot = squad.player_id in bot_player_ids or squad.player_id == bot_bandit.player_id
	
	# retreaat!
	if conditions.has(true) and is_bot:
		squad.attack_move = false
		squad.move_to(player_spawn_points[squad.player_id])
	
func _on_bot_bandit_spawner_timer_timeout():
	bot_bandit_spawner_timer.start()
	
	if bot_bandit_squads.size() > (players.size() + bot_players.size()):
		return
		
	var enemy_idx = bandit_troops[enemy_type_idx].pick_random()
	var data :SquadData = Global.custom_squads[enemy_idx].duplicate()
	data.network_id = 1
	data.player_id = bot_bandit.player_id
	data.node_name = Utils.create_unique_id()
	data.current_tile = spawn_pos.pick_random()
	data.color_idx = 10
	data.team = -1
	spawn_squad(data)
	
func _on_bot_action_timer_timeout():
	bot_action_timer.start()
	
	_bot_bandit_action()
	_bot_players_action()
	
func _bot_bandit_action():
	var enemies = []
	for i in squads:
		if i.team != -1:
			enemies.append(i)
			
	if enemies.empty() or bot_bandit_squads.empty():
		return
		
	var count = int(rand_range(1, 6))
	for _i in count:
		var s = bot_bandit_squads.pick_random()
		if not s.is_moving():
			bot_attack_command(s, enemies.pick_random())
	
func _bot_players_action():
	if bot_squads.empty():
		return
	
	var bot_player :PlayerData = bot_players.pick_random()
	if not bot_squads.has(bot_player.player_id):
		return
		
	if bot_squads[bot_player.player_id].empty():
		return
		
	var enemies = []
	for i in squads:
		if i.team != bot_player.team:
			enemies.append(i)
			
	if enemies.empty() or bot_squads[bot_player.player_id].empty():
		return
		
	var count = int(rand_range(1, 6))
	
	var s = bot_squads[bot_player.player_id]
	for _i in count:
		var e = enemies.pick_random()
		if e.current_tile in e.reinfoce_tiles:
			continue
		
		var i = s.pick_random()
		if not i.is_moving():
			bot_attack_command(i, e)



















