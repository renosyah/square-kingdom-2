extends Node
class_name SquadSpawner

signal on_queue_update
signal on_squads_ready(datas)

export var can_spawn :bool = true
export var max_batch :int = 2
onready var pending_timer = $pending_timer

var queue :Dictionary = {} # {SquadData:Timer}
var _pending_spawns :Array = []
var _datas :Array = []

func add_spawn_queue(armies :Array):
	_datas.append_array(armies)
	
func _add_queue(s :SquadData):
	var spawn_time = 5.0 if s.is_commander else float(s.spawn_time())
	
	# bonus by extra
	if s.extra.has("spawn_time_decrease_percentage"):
		var _v = max(1.0 + s.extra["spawn_time_decrease_percentage"],0.01)
		spawn_time = spawn_time / _v  # dont allow divide by 0
		
	if s.extra.has("spawn_time_decrease_value"):
		spawn_time = spawn_time - s.extra["spawn_time_decrease_value"]
	
	spawn_time = max(spawn_time, 1.0) # min cap is 1 second
	
	var timer = Timer.new()
	timer.wait_time = spawn_time
	timer.autostart = false
	timer.one_shot = true
	timer.connect("timeout", self, "_on_timer_timeout", [s])
	add_child(timer)
	
	queue[s] = timer
	timer.start()
	
	emit_signal("on_queue_update")

func _process(delta):
	if not _datas.empty() and queue.size() < max_batch:
		_add_queue(_datas.front())
		_datas.pop_front()
		_datas.shuffle() # little bit chaos
		
	if not _pending_spawns.empty() and pending_timer.is_stopped() and can_spawn:
		pending_timer.start()
		
		for s in _pending_spawns:
			queue[s].queue_free()
			queue.erase(s)
		
		emit_signal("on_squads_ready", _pending_spawns.duplicate())
		_pending_spawns.clear()
		
func _on_timer_timeout(s :SquadData):
	_pending_spawns.append(s)

