extends MarginContainer

const item = preload("res://assets/user_interface/squad_spawner/item/item.tscn")

export var spawner :NodePath

onready var _spawner :SquadSpawner = get_node_or_null(spawner)
onready var holder = $MarginContainer/VBoxContainer/holder
onready var margin_container = $MarginContainer

func _ready():
	var ok = spawner != null
	set_process(ok)
	
	if ok:
		_spawner.connect("on_squads_ready", self, "_on_squads_ready")
		_spawner.connect("on_queue_update", self, "_on_queue_update")
	
func _process(delta):
	for i in holder.get_children():
		if _spawner.queue.has(i.squad_data):
			var timer :Timer = _spawner.queue[i.squad_data]
			i.update_progress(timer.time_left)
	
func _on_squads_ready(_s):
	_on_queue_update()
	
func _on_queue_update():
	margin_container.visible = not _spawner.queue.empty()
	
	for i in holder.get_children():
		holder.remove_child(i)
		i.queue_free()
		
	for s in _spawner.queue.keys():
		var i = item.instance()
		i.squad_data = s
		holder.add_child(i)
