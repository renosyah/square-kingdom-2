extends Control

const most_result_item_scene = preload("res://menus/battle_result/ui/most_result_item/most_result_item.tscn")
const victory = preload("res://assets/background/victory.png")
const lost = preload("res://assets/background/lost.png")

const victory_wording = [
	["Victory", "The kingdom stands victorious."],
	["Triumph", "Let the bells ring across the realm."],
	["Decisive Victory", "The enemy has been routed."],
	["Glorious Victory", "Our banners fly proudly over the battlefield."],
	["The Crown Prevails", "The realm prospers through strength and resolve."],
	["A Good Day for the Kingdom", "The scribes will remember this one."],
	["Total Domination", "No enemy remains to challenge us."],
	["A Song Worth Singing", "The bards shall tell of this victory for generations."],
]
const lost_wording = [
	["Defeat", "The battle has been lost."],
	["A Bitter Defeat", "Many brave souls will not return home."],
	["Retreat", "Our forces have been forced from the field."],
	["A Dark Day", "The kingdom mourns its fallen."],
	["The Crown Falters", "The realm must endure this setback."],
	["The Field is Lost", "The enemy now claims the battlefield."],
	["Defeat Today, Victory Tomorrow", "The war is not yet over."],
	["That Could Have Gone Better", "The treasury will not enjoy this report."],
]
onready var scoreboard = $CanvasLayer2/Control/scoreboard
onready var texture_rect = $CanvasLayer2/Control/TextureRect
onready var title = $CanvasLayer2/Control/VBoxContainer/MarginContainer2/MarginContainer4/HBoxContainer/MarginContainer/VBoxContainer/title
onready var desc = $CanvasLayer2/Control/VBoxContainer/MarginContainer2/MarginContainer4/HBoxContainer/MarginContainer/VBoxContainer/desc
onready var holders = $CanvasLayer2/Control/VBoxContainer/Control/HBoxContainer

func _ready():
	var is_win :bool = Global.is_win
	texture_rect.texture = victory if is_win else lost
	var wordings =  victory_wording.pick_random() if is_win else lost_wording.pick_random()
	title.text = wordings[0]
	desc.text = wordings[1]
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	display_the_best()
	Global.hide_transition()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			return

func display_the_best():
	for i in holders.get_children():
		holders.remove_child(i)
		i.queue_free()
		
	var datas = _get_most_results()
	for data in datas:
		var item = most_result_item_scene.instance()
		item.most_type = data["type"]
		item.player = data["player"]
		item.value = data["value"]
		holders.add_child(item)

func _get_most_results() -> Array:
	var scores :Array = Global.scores.values() # [ScoreboardData]
	scores.sort_custom(self, "_compare_by_total")
	var best = _dup_score_data(scores)
	
	scores.sort_custom(self, "_compare_by_kill")
	var kill = _dup_score_data(scores)
	
	scores.sort_custom(self, "_compare_by_lost")
	var lost = _dup_score_data(scores)
	
	scores.sort_custom(self, "_compare_by_ff")
	var ff = _dup_score_data(scores)
	
	var datas = [
		{"type":0, "value":best[1].get_total(), "player":best[0]},
		{"type":1, "value":kill[1].kill, "player":kill[0]},
		{"type":2, "value":lost[1].dead, "player":lost[0]},
		{"type":3, "value":ff[1].friendly_fire, "player":ff[0]}
	]
	datas.sort_custom(self, "_compare_value_desc")
	return datas.slice(0, 2)
	
func _compare_value_desc(a, b):
	return a.value > b.value
	
func _dup_score_data(datas) -> Array:
	var a = PlayerData.new()
	a.from_dictionary(datas[0].player_data.to_dictionary())
	var s :Scoreboard.ScoreData = datas[0].score_data
	var b = Scoreboard.ScoreData.new()
	b.kill = s.kill
	b.dead = s.dead
	b.friendly_fire = s.friendly_fire
	
	return [a,b]
	
func _compare_by_total(a, b) -> bool:
	return a.get_total_score() > b.get_total_score()
	
func _compare_by_kill(a, b) -> bool:
	return a.score_data.kill > b.score_data.kill
	
func _compare_by_lost(a, b) -> bool:
	return a.score_data.dead > b.score_data.dead
	
func _compare_by_ff(a, b) -> bool:
	return a.score_data.friendly_fire > b.score_data.friendly_fire
	
func _on_scoreboard_pressed():
	scoreboard.visible = true

func _on_to_lobby_pressed():
	Global.change_scene("res://menus/lobby/lobby.tscn", true)
	
func _on_scoreboard_close():
	scoreboard.visible = false
