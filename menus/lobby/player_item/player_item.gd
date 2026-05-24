extends MarginContainer

signal team_change(team)

var local_player_id :String

var player_network_unique_id :int
var player :PlayerData

onready var player_name = $HBoxContainer/player_name
onready var loading = $HBoxContainer/loading
onready var bg = $HBoxContainer/team/bg
onready var team_label = $HBoxContainer/team/bg/team
onready var potrait = $HBoxContainer/ColorRect/potrait
onready var team = $HBoxContainer/team

func _ready():
	player_name.text = player.player_name
	potrait.texture = EntityIndex.player_potraits[player.potrait_idx]
	bg.self_modulate = EntityIndex.player_colors[player.color_idx]
	team_label.text = "%s" % player.team
	team.disabled = player.player_id != local_player_id
	set_loading(false)

func set_loading(v :bool):
	loading.visible = v

func is_loading() -> bool:
	return loading.visible

func _on_team_pressed():
	player.team += 1
	
	if player.team > 4:
		player.team = 1

	emit_signal("team_change", player.team)
