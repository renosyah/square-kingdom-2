extends Node
class_name BattleAi

# ----------------------------------------
# AI Personality (Player Setting)
# ----------------------------------------
var bot_player :PlayerData
var gameplay_scene
var tile_position_manager

export(float, 0, 1) var aggression := 0.5
export(float, 0, 1) var courage := 0.5
export(float, 0, 1) var intelligence := 0.5

export(float, 1, 3) var reaction_time := 2.0
export(float, 1, 3) var think_interval := 2.0

var _squads := []
var _enemy_squads := []

onready var timer = $Timer

func run():
	timer.wait_time = rand_range(reaction_time, reaction_time + think_interval)
	timer.start()

func stop():
	timer.stop()

func _on_Timer_timeout():
	run()
	_bot_players_action()

func squad_take_damage(squad :BaseSquad):
	if _squads.empty():
		return
		
	if not squad in _squads:
		return
		
	if squad.is_moving() or not squad.is_hero:
		return
		
	var hp = squad.get_members()[0].hp < 200
	
	# save the heroes
	if hp and randf() < courage:
		squad.retreat()
		
func squad_member_dead(squad :BaseSquad, data :SquadData):
	if not squad in _squads:
		return
		
	if squad.current_tile in squad.reinfoce_tiles:
		return
		
	var conditions = [
		data.is_commander,
		randf() < courage, # coward tendencies
		squad.member_alive < 2, # member only 2 left
	]
	
	# retreaat!
	if conditions.has(true):
		squad.retreat()
		
func register_squad(squad :BaseSquad):
	if squad.player_id == bot_player.player_id:
		_squads.append(squad)
		
	elif squad.team != bot_player.team:
		_enemy_squads.append(squad)

func remove_squad(squad :BaseSquad):
	if squad.player_id == bot_player.player_id:
		if _squads.has(squad):
			_squads.erase(squad)
		
	elif squad.team != bot_player.team:
		if _enemy_squads.has(squad):
			_enemy_squads.erase(squad)
		
func _bot_players_action():
	if _squads.empty() or _enemy_squads.empty():
		return
	
	for s in _squads:
		_think(s)
	
func _think(squad :BaseSquad):
	if not is_instance_valid(squad):
		return
		
	if squad.is_moving():
		return
		
	# wait to heal
	if squad.current_tile in squad.reinfoce_tiles:
		if squad.member_alive < squad.total_member:
			return
			
	# make bot use ability if in combat
	if squad.in_melee_engagement() or squad.in_range_engagement():
		if squad.squad_ability_idx != 0:
			AbilityHandle.use_squad_ability(gameplay_scene, bot_player, squad, tile_position_manager,{})
			return
			
	# find target
	var target :BaseSquad = _find_target(squad)
	if not is_instance_valid(target):
		return
		
	var attack_score = _score_attack(squad, target)
	var move_score = _score_move(squad, target)
	if attack_score >= move_score:
		_bot_attack_command(squad, target)
		return
		
	squad.attack_move = true
	squad.move_to(target.current_tile)
	
func _bot_attack_command(squad :BaseSquad, enemy :BaseSquad):
	if is_instance_valid(squad.enemy):
		return
		
	if squad is CavalrySquad and randf() < 0.4:
		squad.chase_enemy = enemy
		squad.chase_target()
		return
		
	squad.attack_move = true
	squad.move_to(enemy.current_tile)

func _find_target(squad :BaseSquad):
	var nearest = null
	var nearest_distance = INF
	for enemy in _enemy_squads:
		if not is_instance_valid(enemy):
			continue
			
		var d = squad.current_tile.distance_squared_to(enemy.current_tile)
		if d < nearest_distance:
			nearest_distance = d
			nearest = enemy
			
	return nearest
	
func _score_attack(squad :BaseSquad, target :BaseSquad):
	var score = 0.0
	score += aggression
	var distance = squad.current_tile.distance_squared_to(target.current_tile)
	score += clamp(1.0 / max(distance, 1), 0, 1)
	score += courage * 0.5
	return score
	
func _score_move(squad :BaseSquad, target :BaseSquad):
	var score = 0.0
	var distance = squad.current_tile.distance_squared_to(target.current_tile)
	score += clamp(distance / 10.0, 0, 1)
	score += intelligence * 0.3
	return score
	
	
	
	
	
	
	
	
	
	
	
