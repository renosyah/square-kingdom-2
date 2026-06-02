extends MarginContainer

const colors = [
	Color(0, 0.647059, 1),
	Color(0.054902, 1, 0),
	Color(1, 0, 0),
	Color(1, 0.537255, 0)
]

const imgs = [
	preload("res://assets/background/best_player.png"),
	preload("res://assets/background/most_kill.png"),
	preload("res://assets/background/most_lost.png"),
	preload("res://assets/background/most_friendly_fire.png")
]

const texts = [
	"Best Player",
	"Most Kills",
	"Most Lost",
	"Most Friendly Fire"
]

export var most_type :int
var player :PlayerData
var value :int

onready var img = $img
onready var title_label = $VBoxContainer/MarginContainer2/HBoxContainer/title
onready var value_label = $VBoxContainer/MarginContainer2/HBoxContainer/value
onready var bg = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer2/team/bg
onready var team = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer2/team/team
onready var potrait = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer2/ColorRect/potrait
onready var player_name = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer2/player_name

func _ready():
	img.texture = imgs[most_type]
	title_label.text ="%s" % texts[most_type]
	value_label.text = "%s" % value
	value_label.self_modulate = colors[most_type]
	team.text = "%s" % player.team
	bg.self_modulate = EntityIndex.player_colors[player.color_idx]
	potrait.texture = EntityIndex.player_potraits[player.potrait_idx]
	player_name.text = player.player_name
