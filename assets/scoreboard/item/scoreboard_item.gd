extends MarginContainer

const sub_item_scene = preload("res://assets/scoreboard/item/sub_item/sub_item.tscn")

var data

onready var bg = $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2/team/bg
onready var team = $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2/team/team
onready var player_name = $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2/player_name
onready var potrait = $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2/ColorRect/potrait

onready var sub_item_holder = $MarginContainer/VBoxContainer/sub_item_holder

onready var total_kill = $MarginContainer/VBoxContainer/HBoxContainer/total_kill
onready var total_dead = $MarginContainer/VBoxContainer/HBoxContainer/total_dead
onready var total_ff = $MarginContainer/VBoxContainer/HBoxContainer/total_ff
onready var total_all = $MarginContainer/VBoxContainer/HBoxContainer/total_all

func _ready():
	var player :PlayerData = data.player_data
	bg.self_modulate = EntityIndex.player_colors[player.color_idx]
	team.text = "%s" % player.team
	player_name.text = player.player_name
	potrait.texture = EntityIndex.player_potraits[player.potrait_idx]
	
	update_ui()
	
func update_ui():
	for i in sub_item_holder.get_children():
		sub_item_holder.remove_child(i)
		i.queue_free()
	
	for s in data.squads.keys():
		var item = sub_item_scene.instance()
		item.data = data.squads[s]
		sub_item_holder.add_child(item)
		
	total_kill.text = "%s" % data.score_data.kill
	total_dead.text = "%s" % data.score_data.dead
	total_ff.text = "%s" % data.score_data.friendly_fire
	total_all.text = "%s" % data.score_data.get_total()
