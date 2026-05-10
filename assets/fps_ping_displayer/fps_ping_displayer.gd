extends MarginContainer

onready var _fps = $VBoxContainer/HBoxContainer/fps
onready var _ping = $VBoxContainer/HBoxContainer2/ping

export var extend :bool

var _id :int
var _is_online :bool
var _enable_pinging :bool
var _ping_value := 0
var _ping_time := 0
var _ping_timer := 0.0
	
func _ready():
	var _network_peer :NetworkedMultiplayerPeer = get_tree().network_peer
	if not is_instance_valid(_network_peer):
		return
		
	_is_online = _network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED
	if not _is_online:
		return
		
	_id = NetworkLobbyManager.get_id()
	_enable_pinging = (_id != Network.PLAYER_HOST_ID)
	
func pinging(delta):
	_ping_timer += delta
	if _ping_timer >= 2.0:
		_ping_timer = 0
		_ping_time = OS.get_ticks_msec()
		rpc_unreliable_id(Network.PLAYER_HOST_ID, "_ping", _id)

remote func _ping(id :int):
	rpc_unreliable_id(id, "_pong")

remote func _pong():
	_ping_value = OS.get_ticks_msec() - _ping_time
	

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
		
	if _is_online and _enable_pinging:
		pinging(_delta)
		_ping.text = "Ping : " + str(_ping_value) + "/ms"
	











