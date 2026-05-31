extends MarginContainer

const squad_card_scene = preload("res://assets/user_interface/squad_card/squad_card.tscn")

var squad_data :SquadData

onready var label_time = $label_time
onready var card_holder = $card_holder
onready var time_progress = $time_progress

func _ready():
	var card = squad_card_scene.instance()
	card.data = squad_data
	card_holder.add_child(card)
	
	label_time.text = Utils.format_time(squad_data.spawn_time)
	time_progress.max_value = squad_data.spawn_time
	time_progress.value = squad_data.spawn_time
	
func update_progress(time_left :float):
	label_time.text = Utils.format_time(time_left)
	time_progress.value = time_left
