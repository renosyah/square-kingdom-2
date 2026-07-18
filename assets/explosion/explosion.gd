extends Spatial

const explode = [
	preload("res://assets/sounds/sfx/eplode_1.wav"),
	preload("res://assets/sounds/sfx/explode_2.wav"),
	preload("res://assets/sounds/sfx/explode_3.wav")
]

onready var animation_player = $AnimationPlayer
onready var audio_stream_player_3d = $AudioStreamPlayer3D

func _ready():
	audio_stream_player_3d.stream = explode.pick_random()
	audio_stream_player_3d.play()
	
	animation_player.play("bam")
	
	yield(get_tree().create_timer(3),"timeout")
	queue_free()
