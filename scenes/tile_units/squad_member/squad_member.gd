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
	
	# backed back to line
	# back to ready animation
	emit_signal("back_in_formation", self)
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
	if iddle:
		translation = squad.get_formation_position(index)
		rotation.y = squad.rotation.y













