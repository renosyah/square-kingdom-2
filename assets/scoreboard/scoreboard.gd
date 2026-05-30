extends MarginContainer
class_name Scoreboard

signal close

const scoreboard_item_scene = preload("res://assets/scoreboard/item/scoreboard_item.tscn")

class ScoreData:
	var squad_potrait_idx :int
	var squad_name :String
	var is_dead :bool
	
	var kill :int
	var dead :int
	var friendly_fire :int
	var total :int
	
	func get_total() -> int:
		return kill - dead - friendly_fire

class ScoreboardData:
	var player_data :PlayerData
	var score_data :ScoreData = ScoreData.new()
	var squads :Dictionary = {} # [Any:ScoreData]
	
	func update_score() -> ScoreData:
		score_data.kill = 0
		score_data.dead = 0
		score_data.friendly_fire = 0
		score_data.total = 0
		
		for s in squads.keys():
			score_data.kill += squads[s].kill
			score_data.dead += squads[s].dead
			score_data.friendly_fire += squads[s].friendly_fire
			score_data.total += squads[s].get_total()
		
		return score_data
	
onready var list_score_holder = $Control/Control/VBoxContainer/SafeArea/MarginContainer/VBoxContainer/ScrollContainer/list_score_holder
var pending_score_update :Array = []
var scores :Dictionary = {} # {PlayerData:ScoreboardData}

func _process(delta):
	if not pending_score_update.empty():
		_update_score(pending_score_update.front())
		pending_score_update.pop_front()

func init_scoreboard(players :Array):
	for p in players:
		scores[p] = ScoreboardData.new()
		scores[p].player_data = PlayerData.new()
		scores[p].player_data.from_dictionary(p.to_dictionary())
		
	ui_update()
	
func add_kill(p :PlayerData, s :SquadData, v :int):
	if not scores.has(p):
		return
		
	if not scores[p].squads.has(s.node_name):
		var d = ScoreData.new()
		d.squad_potrait_idx = s.potrait_idx
		d.squad_name = s.squad_name
		d.is_dead = false
		
		scores[p].squads[s.node_name] = d
		
	scores[p].squads[s.node_name].kill += v
	pending_score_update.append(p)
	
func add_dead(p :PlayerData, s :SquadData, v :int):
	if not scores.has(p):
		return
		
	_register_squad(p,s)
	
	scores[p].squads[s.node_name].dead += v
	pending_score_update.append(p)
	
func add_friendly_fire(p :PlayerData, s :SquadData, v :int):
	if not scores.has(p):
		return
		
	_register_squad(p,s)
	
	scores[p].squads[s.node_name].friendly_fire += v
	pending_score_update.append(p)
	
func set_squad_dead(p :PlayerData, s :SquadData):
	if not scores.has(p):
		return
		
	_register_squad(p,s)
	
	scores[p].squads[s.node_name].is_dead = true
	pending_score_update.append(p)
	
func _register_squad(p,s):
	if not scores[p].squads.has(s.node_name):
		var d = ScoreData.new()
		d.squad_potrait_idx = s.potrait_idx
		d.squad_name = s.squad_name
		d.is_dead = false
		
		scores[p].squads[s.node_name] = d
		
func _update_score(p):
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
		item.data = scores[p]
		list_score_holder.add_child(item)

func _on_back_pressed():
	emit_signal("close")
