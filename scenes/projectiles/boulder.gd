extends IndirectProjectile

const explode = [
	preload("res://assets/sounds/sfx/eplode_1.wav"),
	preload("res://assets/sounds/sfx/explode_2.wav"),
	preload("res://assets/sounds/sfx/explode_3.wav")
]

onready var spatial = $Spatial
onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var animation_player = $AnimationPlayer
onready var mesh_instance_2 = $MeshInstance2

func _process(delta):
	spatial.rotate_x(-5 * delta)
	
func on_stop():
	rotation = Vector3(0, 0, 0)
	animation_player.play("bam")
	
	audio_stream_player_3d.stream = explode.pick_random()
	audio_stream_player_3d.play()
	
	set_process(false)
	_is_ready = true
	#visible = false
	emit_signal("on_reach")
	
	yield(audio_stream_player_3d,"finished")
	yield(get_tree().create_timer(2),"timeout")
	queue_free()
	
