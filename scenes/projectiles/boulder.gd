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
onready var trail_render = $TrailRender
onready var setting_data = Global.setting_data
onready var blood_particle = $blood_particle

func _ready():
	trail_render.render = setting_data.extra_effect
	
func _process(delta):
	spatial.rotate_x(-5 * delta)
	
func on_stop():
	rotation = Vector3(0, 0, 0)
	
	if setting_data.extra_effect:
		animation_player.play("bam")
		blood_particle.emitting = true
	
	audio_stream_player_3d.stream = explode.pick_random()
	audio_stream_player_3d.play()
	
	set_process(false)
	_is_ready = true
	spatial.visible = false
	emit_signal("on_reach")
	
	yield(audio_stream_player_3d,"finished")
	yield(get_tree().create_timer(2),"timeout")
	queue_free()
	
