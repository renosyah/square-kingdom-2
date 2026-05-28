extends IndirectProjectile

onready var trail_render = $TrailRender
onready var setting_data = Global.setting_data
onready var spatial = $Spatial

func _ready():
	trail_render.render = setting_data.extra_effect
	
func _process(delta):
	spatial.rotate_z(-55 * delta)
	
func on_stop():
	set_process(false)
	_is_ready = true
	#spatial.visible = false
	emit_signal("on_reach")
	
	yield(get_tree().create_timer(2),"timeout")
	queue_free()
