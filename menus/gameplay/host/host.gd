extends BaseGameplay

const battle_ai_scene = preload("res://assets/battle_ai/battle_ai.tscn")


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
onready var bot_squad_spawner = $bot_squad_spawner

onready var spawn_pos = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions())

var bot_bandit_squads :Array
var current_wave = 1
var enemy_type_idx :int = 0
var bandit_killed :int = 0
var spawn_size_treshold :int = 1

var battle_ais :Array = []

func _ready():
	for p in bot_players + [bot_bandit]:
		var battle_ai = battle_ai_scene.instance()
		battle_ai.bot_player = p
		battle_ai.gameplay_scene = self
		battle_ai.tile_position_manager = tile_position_manager
		battle_ai.aggression = rand_range(0.3, 0.7)
		battle_ai.courage = rand_range(0.3, 0.8)
		battle_ai.intelligence = randf()
		battle_ai.reaction_time = rand_range(1, 3)
		battle_ai.think_interval = rand_range(1, 3)
		add_child(battle_ai)
		battle_ais.append(battle_ai)
		
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
	
	for i in battle_ais:
		i.run()
		
	if Global.enable_bandit:
		spawn_size_treshold = (players.size() + bot_players.size())
		_on_bot_bandit_spawner_timer_timeout()
		
func on_end(team :int):
	.on_end(team)
	
	bot_bandit_spawner_timer.stop()
	
	for i in battle_ais:
		i.stop()
	
func _on_bot_squad_spawner_on_squads_ready(datas :Array):
	spawn_squads(datas)

func _on_squad_spawned(squad :BaseSquad, data :SquadData):
	._on_squad_spawned(squad, data)
	
	if squad is GuardTowerSquad:
		return
		
	for i in battle_ais:
		i.register_squad(squad)
		
	if squad.player_id == bot_bandit.player_id:
		bot_bandit_squads.append(squad)
		
func _on_squad_dead(squad, data):
	._on_squad_dead(squad, data)
	
	if squad is GuardTowerSquad:
		return
		
	for i in battle_ais:
		i.remove_squad(squad)
	
	_increase_bandit_difficulty(squad)
	
func _on_hero_taking_damage(squad :BaseSquad, amount :int):
	._on_hero_taking_damage(squad, amount)
	
	for i in battle_ais:
		i.squad_take_damage(squad)
	
func _on_squad_member_dead(squad :BaseSquad, member :SquadMember, data :SquadData):
	._on_squad_member_dead(squad, member, data)
	
	if squad is GuardTowerSquad:
		return
		
	for i in battle_ais:
		i.squad_member_dead(squad, data)
		
func _on_bot_bandit_spawner_timer_timeout():
	bot_bandit_spawner_timer.start()
	
	# limit how many can bandit spawn
	if bot_bandit_squads.size() > spawn_size_treshold:
		return
		
	var spawn_id = player_spawn_points[bot_bandit.player_id]
	var closed = not tile_position_manager.get_positions()[spawn_id].empty()
	if closed:
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
	data.current_tile = spawn_id
	spawn_squad(data)
	
func _increase_bandit_difficulty(squad :BaseSquad):
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

















