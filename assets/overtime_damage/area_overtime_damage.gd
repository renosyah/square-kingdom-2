extends Node

signal on_target_affected(squad)

var tiles :Array
var unit_position :Dictionary = {}
var duration :float
var apply_once :bool

onready var timer = $overtime
onready var timeout = $timeout

var _applied :Array = []

func _ready():
	yield(get_tree(), "idle_frame")
	timeout.wait_time = duration
	timeout.start()
	_on_overtime_timeout()
	
func _on_overtime_timeout():
	timer.start()
	
	for tile_id in tiles:
		if not unit_position.has(tile_id):
			continue
			
		var unit_positions :Array = unit_position[tile_id]
		if unit_positions.empty():
			continue
			
		_affected_positions(unit_positions)
		
func _affected_positions(unit_positions :Array):
	for enemy_squad in unit_positions:
		if not is_instance_valid(enemy_squad):
			continue
			
		if apply_once:
			_applied.append(enemy_squad)
			
		if not (enemy_squad in _applied):
			emit_signal("on_target_affected", enemy_squad)
		
func _on_timeout_timeout():
	timer.stop()
	queue_free()
