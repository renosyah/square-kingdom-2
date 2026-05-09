extends Node
class_name BatchSpawner

signal on_spawn(data)
signal on_finish

var _datas := []
var _batch_size := 20
var _index := 0
var _running := false

func _ready():
	set_process(false)

func start(p_datas:Array, p_batch_size:int = 20):
	_datas = p_datas
	_batch_size = p_batch_size
	_index = 0
	_running = true
	set_process(true)
	
func is_running() -> bool:
	return _running
	
func _process(delta):
	if !_running:
		return
		
	for i in range(_batch_size):
		if _index >= _datas.size():
			_running = false
			set_process(false)
			emit_signal("on_finish")
			return
			
		_on_spawn(_datas[_index])
		_index += 1

func _on_spawn(data):
	emit_signal("on_spawn", data)
