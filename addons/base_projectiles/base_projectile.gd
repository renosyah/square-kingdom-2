extends Spatial
class_name BaseProjectile

signal on_reach

export var to :Vector3
export var speed :float = 12.0
export var max_range :float = 5.0
export var is_master :bool

var _dir :Vector3
var _travel_distance :float = 0
var _is_ready :bool = true

func _ready():
	visible = false
	set_process(false)
	set_as_toplevel(true)

func launch():
	visible = true
	_dir = global_position.direction_to(to)
	_travel_distance = 0
	_is_ready = false
	set_process(true)
	look_at(to, Vector3.UP)
	
func on_travel(delta):
	if _travel_distance > max_range:
		on_stop()
		return
		
	var vel = speed * delta
	translation += _dir * vel
	_travel_distance += vel
	
func _process(delta):
	on_travel(delta)
	
func on_stop():
	set_process(false)
	_is_ready = true
	visible = false
	emit_signal("on_reach")
	



