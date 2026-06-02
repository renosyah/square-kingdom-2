extends MarginContainer

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

onready var img = $img
onready var title = $VBoxContainer/MarginContainer2/title
onready var bg = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer2/team/bg
onready var team = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer2/team/team
onready var potrait = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer2/ColorRect/potrait
onready var player_name = $VBoxContainer/MarginContainer/MarginContainer/HBoxContainer2/player_name

func _ready():
	img.texture = imgs[most_type]
	title.text = texts[most_type]
	team.text = "%s" % player.team
	bg.self_modulate = EntityIndex.player_colors[player.color_idx]
	potrait.texture = EntityIndex.player_potraits[player.potrait_idx]
	player_name.text = player.player_name
