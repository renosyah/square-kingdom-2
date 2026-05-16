extends Spatial
class_name SquadMember

signal attack_performed(member, enemy)

export var headgear :PackedScene
export var armor :PackedScene
export var melee_weapon :PackedScene
export var range_weapon :PackedScene
export var speed :float = 2

var squad

var iddle :bool = true
var enemy = null
var enemy_assign :bool = false
var is_dead :bool = false

func _ready():
	set_process(true)
	set_physics_process(false)
	
func dead():
	set_process(false)
	is_dead = true

func melee_attack():
	iddle = false
	
	# walk closer to enemy
	# perform melee animation
	emit_signal("attack_performed", self, enemy)
	
	iddle = true
	enemy = null
	
func range_attack():
	iddle = false
	
	# do shoting animation
	# if projectile hit enemy
	emit_signal("attack_performed", self, enemy)
	
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













