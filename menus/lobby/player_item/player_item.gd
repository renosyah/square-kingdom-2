extends MarginContainer

var player_network_unique_id :int
var no :int
var player :PlayerData

onready var player_name = $HBoxContainer/player_name
onready var loading = $HBoxContainer/loading
onready var bg = $HBoxContainer/bg
onready var no_label = $HBoxContainer/bg/no_label
onready var potrait = $HBoxContainer/ColorRect/potrait

func _ready():
	no_label.text = "%s" % no
	player_name.text = player.player_name
	potrait.texture = Global.player_potraits[player.potrait_idx]
	bg.self_modulate = Global.player_colors[player.color_idx]
	set_loading(false)

func set_loading(v :bool):
	loading.visible = v

func is_loading() -> bool:
	return loading.visible
