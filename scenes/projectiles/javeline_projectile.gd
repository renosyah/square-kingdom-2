extends IndirectProjectile

func on_stop():
	set_process(false)
	_is_ready = true
	#visible = false
	emit_signal("on_reach")
