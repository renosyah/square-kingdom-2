extends Spatial
class_name SquadMember

signal on_member_dead(member)
signal attack_performed(member, target, target_idx, amount)

export var headgear :PackedScene
export var armor :PackedScene
export var shield :PackedScene
export var melee_weapon :PackedScene
export var range_weapon :PackedScene

export var hp :int = 100
export var max_hp :int = 100

var squad

var iddle :bool = true
var target_idx :int 
var enemy = null
var enemy_assign :bool = false
var is_dead :bool = false

func _ready():
	set_process(true)
	set_physics_process(false)
	
func set_dead():
	set_process(false)
	is_dead = true
	emit_signal("on_member_dead", self)
	
func prepare_melee_weapon():
	pass
	
func prepare_range_weapon():
	pass
	
func melee_attack():
	iddle = false
	
	# walk closer to enemy
	# perform melee animation
	emit_signal("attack_performed", self, enemy, target_idx, 0)
	
	iddle = true
	enemy = null
	
func range_attack():
	iddle = false
	
	# do shoting animation
	# if projectile hit enemy
	emit_signal("attack_performed", self, enemy, target_idx, 0)
	
	# back to ready animation
	iddle = true
	enemy = null
	
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











