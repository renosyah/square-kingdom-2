extends Spatial
class_name SquadMember

var iddle :bool = true
var enemy = null

func melee_attack():
	iddle = false

func range_attack():
	iddle = false
