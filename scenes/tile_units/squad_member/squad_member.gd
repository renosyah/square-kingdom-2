extends Spatial
class_name SquadMember

signal attack_performed(enemy)

var iddle :bool = true
var enemy = null

func melee_attack():
	iddle = false
	# do shoting animation
	# if projectile hit enemy
	emit_signal("attack_performed", enemy)
	
	# back to ready animation
	iddle = true

func range_attack():
	iddle = false
	# walk closer to enemy
	# perform melee animation
	emit_signal("attack_performed", enemy)
	
	# backed back to line
	# back to ready animation
	iddle = true
