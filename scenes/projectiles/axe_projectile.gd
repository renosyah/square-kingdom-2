extends IndirectProjectile

onready var spatial = $Spatial

func _process(delta):
	spatial.rotate_x(-45 * delta)
	
func on_stop():
	set_process(false)
	_is_ready = true
	#visible = false
	emit_signal("on_reach")
