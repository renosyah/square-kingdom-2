extends BaseProjectile
class_name IndirectProjectile

# indirect projectile
# not only travel from point A to B in straign line
# it also loobed it self to top then botom on the way
var _top_down_point :Vector3
export var threshold :float = 0.3

# override
func launch():
	#.launch()
	_age = 0
	_top_down_point = to + Vector3(0, max_range, 0)
	visible = true
	_dir = global_position.direction_to(_top_down_point)
	_travel_distance = 0
	_is_ready = false
	set_process(true)
	look_at(_top_down_point, Vector3.UP)
	
# override
func on_travel(delta):
	#.on_travel(delta)
	var dist = global_position.distance_to(to)
	if dist < threshold or _age > lifetime:
		on_stop()
		return
	
	var vel = speed * delta
	if _top_down_point.y > to.y:
		_top_down_point += Vector3.DOWN * vel
	
	_dir = global_position.direction_to(_top_down_point)
	translation += _dir * vel
	_age += delta
	
	if _dir.length() > 0.001:
		var dot = abs(_dir.dot(Vector3.UP))
		if dot < 0.999:
			look_at(_top_down_point, Vector3.UP)
