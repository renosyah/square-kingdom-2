extends Node
class_name BattleAi

signal attack(squad, target)
signal move(squad, tile)

# ----------------------------------------
# AI Personality (Player Setting)
# ----------------------------------------

export(float, 0, 1) var aggression := 0.5
export(float, 0, 1) var courage := 0.5
export(float, 0, 1) var intelligence := 0.5

export(float, 1, 3) var reaction_time := 2.0
export(float, 1, 3) var think_interval := 2.0

var squads := []
var enemy_squads := []

onready var timer = $Timer

func run():
	timer.wait_time = rand_range(reaction_time, reaction_time + think_interval)
	timer.start()

func _on_Timer_timeout():
	run()
	
	for squad in squads:
		_think(squad)
		
func _think(squad):
	var target = _find_target(squad)
	if target == null:
		return

	var attack_score = _score_attack(squad, target)
	var move_score = _score_move(squad, target)
	if attack_score >= move_score:
		emit_signal("attack", squad, target)
	else:
		emit_signal("move", squad, target.current_tile)
		
func _find_target(squad):
	var nearest = null
	var nearest_distance = INF
	for enemy in enemy_squads:
		if enemy == null:
			continue
	
		var d = squad.current_tile.distance_to(enemy.current_tile)
		if d < nearest_distance:
			nearest_distance = d
			nearest = enemy
			
	return nearest
	
func _score_attack(squad, target):
	var score = 0.0
	score += aggression
	var distance = squad.current_tile.distance_to(target.current_tile)
	score += clamp(1.0 / max(distance, 1), 0, 1)
	score += courage * 0.5
	return score
	
func _score_move(squad, target):
	var score = 0.0
	var distance = squad.current_tile.distance_to(target.current_tile)
	score += clamp(distance / 10.0, 0, 1)
	score += intelligence * 0.3
	return score



