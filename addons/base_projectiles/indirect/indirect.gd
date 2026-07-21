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
	_look_at(_dir, _top_down_point)
	
# override
func on_travel(delta):
	#.on_travel(delta)
	
	var pos :Vector3 = global_position
	
	# alternative uses lifetime 
	# so projectile dont life stuck forever
	if _age > lifetime:
		on_stop()
		return
		
#	# uses expensive distance calculation
#	var dist = global_position.distance_to(to)
#	if dist < threshold:
#		on_stop()
#		return
	
	# use cheap dot product
	if (pos - _top_down_point).dot(_dir) >= 0:
		on_stop()
		return
	
	var vel = speed * delta
	if _top_down_point.y > to.y: # add 0.5 for good measures LOL
		_top_down_point += Vector3.DOWN * vel
		_look_at(_dir, _top_down_point)
		
	_dir = pos.direction_to(_top_down_point)
	translation += _dir * vel
	_age += delta
	
func _look_at(dir :Vector3, to :Vector3):
	if dir.length() > 0.001:
		var dot = abs(dir.dot(Vector3.UP))
		if dot < 0.999:
			look_at(to, Vector3.UP)
