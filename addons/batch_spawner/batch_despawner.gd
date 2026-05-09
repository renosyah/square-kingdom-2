extends Node
class_name BatchDespawner

signal on_finish

var _nodes := []
var _batch_size := 20
var _index := 0
var _running := false

func _ready():
	set_process(false)

func start(p_nodes:Array, p_batch_size:int = 20):
	_nodes = p_nodes
	_batch_size = p_batch_size
	_index = 0
	_running = true
	set_process(true)

func _process(delta):
	if !_running:
		return
		
	for i in range(_batch_size):
		if _index >= _nodes.size():
			_running = false
			set_process(false)
			emit_signal("on_finish")
			return
			
		var _node = _nodes[_index]
		if is_instance_valid(_node):
			_node.queue_free()
			
		_index += 1
