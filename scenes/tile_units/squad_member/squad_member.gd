extends Spatial
class_name SquadMember

signal on_member_dead(member)
signal on_set_damage_to_target(member, target, target_idx, amount)
signal on_set_damage_to_tile(member, tile, amount)

export var headgear :PackedScene
export var armor :PackedScene
export var shield :PackedScene
export var melee_weapon :PackedScene
export var range_weapon :PackedScene
export var material :SpatialMaterial

export var hp :int = 100
export var max_hp :int = 100

var squad

var iddle :bool = true
var target_idx :int 
var enemy = null
var enemy_assign :bool = false
var is_dead :bool = false

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
	pass
	
func set_dead():
	set_process(false)
	is_dead = true
	
	rpc("_on_member_dead")
	
remotesync func _on_member_dead():
	set_process(false)
	is_dead = true
	dead()
	
func dead():
	emit_signal("on_member_dead", self)
	
func prepare_melee_weapon():
	pass
	
func prepare_range_weapon():
	pass
	
func melee_attack():
	pass
	
func range_attack():
	pass
	
func moving(delta :float):
	if is_dead:
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
		set_dead()











