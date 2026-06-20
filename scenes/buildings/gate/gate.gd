extends Spatial

const door_close = preload("res://assets/sounds/sfx/door_close.wav")
const door_open = preload("res://assets/sounds/sfx/door_open.wav")

export var material :SpatialMaterial
var tile_ids :Array
var unit_position :Dictionary = {} # {Vector2 : [BaseTileUnit]}
var team :int
var keep_open :bool

onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var animation_player = $AnimationPlayer
onready var mesh_instance = $MeshInstance
onready var door = $door
onready var queue = $queue_task
onready var door_2 = $Spatial/door2

var is_open = false
var _operating :bool = false

func _ready():
	mesh_instance.set_surface_material(1, material)
	door.set_surface_material(1, material)
	door_2.set_surface_material(1, material)
	Global.connect("on_global_tick", self, "_on_global_tick")
	
func _on_global_tick():
	if _operating:
		return
		
	var at_gate = _squad_at_gates(not keep_open)
	if at_gate and not is_open:
		_operating = true
		queue.add_task(self, "open_gate")
	
	if not at_gate and is_open:
		_operating = true
		queue.add_task(self, "close_gate")
	
func _squad_at_gates(same_team :bool) -> bool:
	for id in tile_ids:
		if not same_team:
			if not unit_position[id].empty():
				return true
				
		if unit_position[id].empty():
			continue
			
		for unit in unit_position[id]:
			if is_instance_valid(unit):
				if unit.team == team:
					return true
	return false
	
func open_gate():
	audio_stream_player_3d.stream = door_close
	audio_stream_player_3d.play()
	
	animation_player.play("open_door")
	yield(animation_player, "animation_finished")
	is_open = true
	_operating = false

func close_gate():
	audio_stream_player_3d.stream = door_open
	audio_stream_player_3d.play()
	
	animation_player.play("close_door")
	yield(animation_player, "animation_finished")
	is_open = false
	_operating = false










