extends Control

export var text :String

onready var label = $MarginContainer/CenterContainer/Label
onready var animation_player = $AnimationPlayer

func show():
	label.text = text
	animation_player.play("pop")
