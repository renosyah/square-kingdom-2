extends RangeWeapon

onready var mesh_instance = $MeshInstance

func _ready():
	mesh_instance.visible = true
	
func pull():
	.pull()
	
	mesh_instance.visible = true
	
func release():
	.release()
	
	mesh_instance.visible = false
	
func get_projectile_damage(_target, _enemy_squad_attribute :Array) -> int:
	var dmg :int = attack_damage + (attack_damage * bonus_damage)
	return int(rand_range(attack_damage, dmg))
