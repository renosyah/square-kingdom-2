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
	
func get_projectile_damage(_target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[4]: # have shield
		return attack_damage + int(attack_damage * bonus_damage)
	return attack_damage
