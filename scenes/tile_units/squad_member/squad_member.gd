extends Spatial
class_name SquadMember

signal on_member_dead(member)
signal on_set_damage_to_target(member, target, target_idx, amount)
signal on_set_damage_to_tile(member, tile, amount)
signal on_play_shot_audio(stream)

export var headgear :PackedScene
export var armor :PackedScene
export var shield :PackedScene
export var melee_weapon :PackedScene
export var range_weapon :PackedScene
export var material :SpatialMaterial
export var on_horse :bool = false

export var banner_icon :StreamTexture
export var is_bannerman :bool = false

export var hp :int = 100
export var max_hp :int = 100

var squad
var attacked_by :NodePath

var iddle :bool = true
var target_idx :int 
var enemy = null
var enemy_assign :bool = false
export var is_dead :bool = false

var range_mode :bool
var melee_mode :bool

var _combat_sound :AudioStreamPlayer3D

func _ready():
	_combat_sound = AudioStreamPlayer3D.new()
	_combat_sound.bus = Global.bus_sfx
	add_child(_combat_sound)
	
	set_process(true)
	set_physics_process(false)
	
func resurect():
	hp = max_hp
	is_dead = false
	set_process(true)
	translation = squad.global_position
	
func set_dead():
	set_process(false)
	is_dead = true
	
func prepare_melee_weapon():
	pass
	
func prepare_range_weapon():
	pass
	
func melee_attack():
	pass
	
func range_attack():
	pass
	
func melee_has_splash() -> bool:
	return false
	
func range_has_splash() -> bool:
	return false
	
func range_accuration() -> float:
	return 0.25
	
func _look_at(pos :Vector3):
	var _pos = pos
	_pos.y = global_position.y
	
	var _dir = global_position.direction_to(_pos)
	if _dir.length() > 0.001:
		var dot = abs(_dir.dot(Vector3.UP))
		if dot < 0.999:
			look_at(_pos, Vector3.UP)
			
func moving(delta :float):
	if is_dead or not squad.visible:
		return
		
	if iddle: # make this unit in formation
		rotation.y = lerp_angle(rotation.y, squad.rotation.y, 5 * delta)
	
func _process(delta):
	moving(delta)

func take_damage(amount :int):
	if is_dead:
		return
		
	hp = int(clamp(hp - amount, 0, max_hp))
	
	if hp <= 0:
		is_dead = true # safe guard
		# set_dead() <- dont set, this will be called later via RPC on squad
		emit_signal("on_member_dead", self)











