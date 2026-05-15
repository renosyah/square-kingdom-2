extends Spatial
class_name SquadMember

signal attack_performed(member, enemy)

export var index :int
var squad

var iddle :bool = true
var enemy = null
var moving :bool

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
	
func _process(delta):
	if iddle: # make this unit in formation
		var pos = squad.get_formation_position(index)
		translation = translation.linear_interpolate(pos, 5 * delta)
		rotation.y = squad.rotation.y













