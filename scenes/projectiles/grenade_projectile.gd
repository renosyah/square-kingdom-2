extends IndirectProjectile

const explode = preload("res://assets/sounds/sfx/explode.wav")

onready var spatial = $Spatial
onready var animation_player = $AnimationPlayer

func launch():
	.launch()
	
	spatial.visible = true
	
func _process(delta):
	if visible:
		spatial.rotate_x(-25 * delta)
	
func on_stop():
	_age = 0
	set_process(false)
	yield(get_tree().create_timer(rand_range(0.2,0.6)),"timeout")
	
	emit_signal("on_reach")
	spatial.visible = false
	
	var audio = Global.get_audio_player()
	if audio:
		audio.translation = global_position
		audio.stream = explode
		audio.play()
	
	animation_player.play("explode")
	yield(get_tree().create_timer(3),"timeout")
	
	_is_ready = true
	visible = false
