extends IndirectProjectile

func on_stop():
	_age = 0
	set_process(false)
	emit_signal("on_reach")
	
	yield(get_tree().create_timer(1),"timeout")
	_is_ready = true
	visible = false
