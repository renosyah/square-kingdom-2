extends BaseGameplay

const wave_per_stage = 3
const killed_treshold :int = 5
const bandit_names = ["Bandit", "Deserter", "Renegade", "Outlaw", "Brigand", "Raider"]
const bandit_troops = [
	[0,3,4,5],
	[3,4,5,6,7,8],
	[3,4,5,6,7,8,15,16,17],
	[3,4,5,6,7,8,15,16,17,21,22,23],
]

onready var bot_bandit_spawner_timer = $bot_bandit_spawner_timer
onready var bot_action_timer = $bot_action_timer
onready var bot_squad_spawner = $bot_squad_spawner

onready var spawn_pos = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions())

var bot_bandit_squads :Array
var current_wave = 1
var enemy_type_idx :int = 0
var bandit_killed :int = 0

var bot_player_ids :Array
var bot_squads :Dictionary = {} # {bot_id:[BaseSquad]}
var bot_cowardices :Dictionary = {}
var bot_aggresives :Dictionary = {}
var spawn_size_treshold :int = 1

var bot_squad_heroes = []

func _ready():
	for i in bot_players:
		bot_cowardices[i.player_id] = rand_range(0.3, 0.7)
		bot_aggresives[i.player_id] = rand_range(0.3, 0.8)
		bot_player_ids.append(i.player_id)

func _on_all_player_ready():
	._on_all_player_ready()
	
	bot_cowardices[bot_bandit.player_id] = 0.5
	
	yield(get_tree().create_timer(1),"timeout")
	var _squads = []
	
	# spawn host squad and all bots squads
	for p in bot_players:
		_squads.append_array(Global.prepare_army(
			Global.bot_player_armies[p.player_id],
			player_spawn_points[p.player_id], p
		))
		
	bot_squad_spawner.add_spawn_queue(_squads)
	bot_action_timer.start()
	
	if Global.enable_bandit:
		spawn_size_treshold = (players.size() + bot_players.size())
		_on_bot_bandit_spawner_timer_timeout()

func _on_bot_squad_spawner_on_squads_ready(datas :Array):
	spawn_squads(datas)
	
func bot_attack_command(squad :BaseSquad, enemy :BaseSquad):
	if is_end:
		return
		
	if is_instance_valid(squad.enemy):
		return
		
	if squad is CavalrySquad and randf() < 0.4:
		squad.chase_enemy = enemy
		squad.chase_target()
		return
		
	squad.attack_move = true
	squad.move_to(enemy.current_tile)
	
func _on_squad_spawned(squad :BaseSquad, data :SquadData):
	._on_squad_spawned(squad, data)
	
	if is_end:
		return
		
	if squad is GuardTowerSquad:
		return
		
	if squad.player_id in bot_player_ids:
		if not bot_squads.has(squad.player_id):
			bot_squads[squad.player_id] = []
		
		bot_squads[squad.player_id].append(squad)
		if data.is_hero:
			bot_squad_heroes.append(squad)
		
	if squad.player_id == bot_bandit.player_id:
		bot_bandit_squads.append(squad)
		
func _on_squad_dead(squad, data):
	._on_squad_dead(squad, data)
	
	if is_end:
		return
		
	if squad is GuardTowerSquad:
		return
		
	if bot_squad_heroes.has(squad):
		bot_squad_heroes.erase(squad)
	
	if squad.player_id in bot_player_ids:
		bot_squads[squad.player_id].erase(squad)
	
	if squad.player_id == bot_bandit.player_id:
		bot_bandit_squads.erase(squad)
		bandit_killed += 1
		
	# event madness has his limit
	if spawn_size_treshold > 8:
		return
		
	# up progress, facing more formidable bandit
	if bandit_killed > killed_treshold:
		bandit_killed = 0
		current_wave += 1
		
		if current_wave == wave_per_stage:
			enemy_type_idx = int(clamp(enemy_type_idx + 1, 0, bandit_troops.size() - 1))
			current_wave = 0
			spawn_size_treshold += 1
			
func _on_hero_taking_damage(squad :BaseSquad, amount :int):
	._on_hero_taking_damage(squad, amount)
	
	if is_end:
		return
		
	if bot_squad_heroes.empty():
		return
		
	if not squad.player_id in bot_player_ids:
		return
		
	if squad.is_moving():
		return
		
	if not squad in bot_squad_heroes:
		return
		
	var hp = squad.get_members()[0].hp < 60
	
	# save the heroes
	if hp and randf() < bot_cowardices[squad.player_id]:
		squad.retreat()
	
func _on_squad_member_dead(squad :BaseSquad, member :SquadMember, data :SquadData):
	._on_squad_member_dead(squad, member, data)
	
	if is_end:
		return
		
	if squad is GuardTowerSquad:
		return
		
	var is_bot = squad.player_id in (bot_player_ids + [bot_bandit.player_id])
	if not is_bot:
		return
		
	var conditions = [
		data.is_commander,
		randf() < bot_cowardices[squad.player_id], # coward tendencies
		squad.member_alive < 2, # member only 2 left
	]
	
	# retreaat!
	if conditions.has(true):
		squad.retreat()
	
func _on_bot_bandit_spawner_timer_timeout():
	if is_end:
		return
		
	bot_bandit_spawner_timer.start()
	
	# limit how many can bandit spawn
	if bot_bandit_squads.size() > spawn_size_treshold:
		return
		
	var enemy_idx = bandit_troops[enemy_type_idx].pick_random()
	var data :SquadData = Global.template_squads[enemy_idx].duplicate()
	data.network_id = 1
	
	if data.scene_idx in [0,1]:
		data.squad_name = bandit_names.pick_random()
		
	data.player_id = bot_bandit.player_id
	data.node_name = Utils.create_unique_id()
	data.current_tile = spawn_pos.pick_random()
	data.color_idx = 10
	data.team = -1
	data.current_tile = player_spawn_points[bot_bandit.player_id]
	spawn_squad(data)
	
func _on_bot_action_timer_timeout():
	if is_end:
		return
		
	bot_action_timer.start()
	_bot_players_action()
	
	if Global.enable_bandit:
		_bot_bandit_action()
		
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
	var bot_aggresive = bot_aggresives[bot_player.player_id]
	
	for _i in count:
		var go = randf() < bot_aggresive
		var e = enemies.pick_random()
		
		if e.current_tile in e.reinfoce_tiles or not go:
			continue
		
		var i :BaseSquad = s.pick_random()
		go = randf() < bot_aggresive
		if i.member_alive < i.total_member or not go:
			continue
			
		# make bot use ability if in combat
		if i.in_melee_engagement() or i.in_range_engagement():
			if i.squad_ability_idx != 0:
				use_squad_ability(i)
				
			continue
			
		if not i.is_moving():
			bot_attack_command(i, e)



















