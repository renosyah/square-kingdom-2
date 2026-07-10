extends Node

signal on_target_affected(squad)

var tiles :Array
var unit_position :Dictionary = {}
var duration :float = 25
var attach_targets :Array # any

onready var timeout = $timeout

func _ready():
	Global.connect("on_global_tick", self, "_on_global_tick")
	timeout.wait_time = duration
	timeout.start()
	
func _on_global_tick():
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
			
		while not attach_targets.empty():
			enemy_squad.add_child(attach_targets.front())
			attach_targets.pop_front()
			
		queue_free()
		return
		
func _on_timeout_timeout():
	queue_free()
