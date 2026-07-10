extends Spatial
class_name TileTrap

const siege_break = preload("res://assets/sounds/sfx/siege_break_4.wav")

var tile :Vector2
var unit_position :Dictionary = {}
var duration :float = -1
var attach_targets :Array # any

onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var expired = $expired

var _trap_used :bool

func _ready():
	Global.connect("on_global_tick", self, "_on_global_tick")
	
	if duration > 0:
		expired.wait_time = duration
		expired.start()
	
func _on_global_tick():
	if _trap_used:
		return
		
	if not unit_position.has(tile):
		return
		
	var unit_positions :Array = unit_position[tile]
	if unit_positions.empty():
		return
		
	_affected_positions(unit_positions)
	
func _affected_positions(unit_positions :Array):
	for enemy_squad in unit_positions:
		if not is_instance_valid(enemy_squad):
			continue
			
		_trap_used = true
		
		while not attach_targets.empty():
			enemy_squad.add_child(attach_targets.front())
			attach_targets.pop_front()
			
		audio_stream_player_3d.stream = siege_break
		audio_stream_player_3d.play()
		yield(get_tree().create_timer(2),"timeout")
		
		queue_free()
		return
		
func _on_expired_timeout():
	queue_free()
