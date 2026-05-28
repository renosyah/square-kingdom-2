extends Spatial
class_name SiegeEngine

signal on_set_damage_to_tile(engine, tile, amount)

export var attack_damage :int = 32

var squad

var iddle :bool = true
var tile_target :Vector2
var target_position :Vector3

var _combat_sound :AudioStreamPlayer3D

func _ready():
	_combat_sound = AudioStreamPlayer3D.new()
	_combat_sound.bus = Global.bus_sfx
	add_child(_combat_sound)
	
	set_process(true)
	set_physics_process(false)
	
func attack():
	pass
	
func moving(delta :float):
	rotation.y = lerp_angle(rotation.y, squad.rotation.y, 5 * delta)
	
func _process(delta):
	moving(delta)

func _can_look_at(pos :Vector3, to_pos :Vector3, dir :Vector3) -> bool:
	var _pos = pos
	_pos.y = pos.y
	
	if dir.length() > 0.001:
		var dot = abs(dir.dot(Vector3.UP))
		return dot < 0.999
		
	return false
