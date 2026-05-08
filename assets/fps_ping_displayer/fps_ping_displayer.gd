extends MarginContainer

onready var _fps = $VBoxContainer/HBoxContainer/fps
onready var _ping = $VBoxContainer/HBoxContainer2/ping

export var extend :bool

# Called when the node enters the scene tree for the first time.
func _ready():
	Network.connect("on_ping", self, "on_ping")
	
func on_ping(v :int):
	_ping.text = "Ping : " + str(v) + "/ms"
	
func _process(_delta):
	if extend:
		var fps = Engine.get_frames_per_second()
		var draw_calls = Performance.get_monitor(
			Performance.RENDER_DRAW_CALLS_IN_FRAME
		)
		var objects = Performance.get_monitor(
			Performance.OBJECT_COUNT
		)
		var memory = Performance.get_monitor(
			Performance.MEMORY_STATIC
		) / 1024 / 1024
		var nodes = Performance.get_monitor(
			Performance.OBJECT_NODE_COUNT
		)
		var orphan = Performance.get_monitor(
			Performance.OBJECT_ORPHAN_NODE_COUNT
		)
	
		_fps.text = "FPS: " + str(fps) + "\n" + \
			"Draw Calls: " + str(draw_calls) + "\n" + \
			"Objects: " + str(objects) + "\n" + \
			"Nodes: " + str(nodes) + "\n" + \
			"Orphans: " + str(orphan) + "\n" + \
			"Memory: " + str(round(memory)) + " MB"
	else:
		_fps.text = "Fps : " +  str(Engine.get_frames_per_second())
