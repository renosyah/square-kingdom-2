extends IndirectProjectile

onready var trail_render = $TrailRender
onready var setting_data = Global.setting_data

func _ready():
	trail_render.render = setting_data.extra_effect
	
func on_stop():
	_age = 0
	set_process(false)
	_is_ready = true
	emit_signal("on_reach")
	
	yield(get_tree().create_timer(2),"timeout")
	queue_free()
