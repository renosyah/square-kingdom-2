extends MarginContainer
class_name Scoreboard

signal close

const scoreboard_item_scene = preload("res://assets/scoreboard/item/scoreboard_item.tscn")

class ScoreData:
	var kill :int
	var dead :int
	var friendly_fire :int
	var total :int
	
	func get_total() -> int:
		return kill - dead - friendly_fire

class ScoreboardData:
	var scoreData :ScoreData = ScoreData.new()
	var squads :Dictionary = {} # [SquadData:ScoreData]
	
	func update_score() -> ScoreData:
		scoreData.kill = 0
		scoreData.dead = 0
		scoreData.friendly_fire = 0
		scoreData.total = 0
		
		for s in squads.keys():
			scoreData.kill += squads[s].kill
			scoreData.dead += squads[s].dead
			scoreData.friendly_fire += squads[s].friendly_fire
			scoreData.total += squads[s].get_total()
		
		return scoreData
	
onready var list_score_holder = $Control/Control/VBoxContainer/SafeArea/MarginContainer/VBoxContainer/ScrollContainer/list_score_holder

var scores :Dictionary = {} # {PlayerData:ScoreboardData}

func init_scoreboard(players :Array):
	for p in players:
		scores[p] = ScoreboardData.new()
		
	ui_update()
	
func add_kill(p :PlayerData, s :SquadData, v :int):
	if not scores.has(p):
		return
		
	if not scores[p].squads.has(s):
		scores[p].squads[s] = ScoreData.new()
		
	scores[p].squads[s].kill += v
	scores[p].update_score()
	ui_update(p.player_id)
	
func add_dead(p :PlayerData, s :SquadData, v :int):
	if not scores.has(p):
		return
		
	if not scores[p].squads.has(s):
		scores[p].squads[s] = ScoreData.new()
		
	scores[p].squads[s].dead += v
	scores[p].update_score()
	ui_update(p.player_id)
	
func add_friendly_fire(p :PlayerData, s :SquadData, v :int):
	if not scores.has(p):
		return
		
	if not scores[p].squads.has(s):
		scores[p].squads[s] = ScoreData.new()
		
	scores[p].squads[s].friendly_fire += v
	scores[p].update_score()
	ui_update(p.player_id)

func ui_update(player_id :String = "none"):
	var prev_item = get_node_or_null(
		NodePath("%s/%s" % [list_score_holder.get_path(), player_id])
	)
	if prev_item != null:
		prev_item.update_ui()
		return
	
	for i in list_score_holder.get_children():
		list_score_holder.remove_child(i)
		i.queue_free()
		
	for p in scores.keys():
		var item = scoreboard_item_scene.instance()
		item.name = p.player_id
		item.player = p
		item.data = scores[p]
		list_score_holder.add_child(item)

func _on_back_pressed():
	emit_signal("close")
