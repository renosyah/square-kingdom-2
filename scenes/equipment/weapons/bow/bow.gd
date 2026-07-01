extends RangeWeapon

onready var mesh_instance = $MeshInstance
onready var mesh_instance_2 = $MeshInstance2

func _ready():
	release()
	
func pull():
	.pull()
	
	mesh_instance.visible = false
	mesh_instance_2.visible = true
	
func release():
	.release()
	
	mesh_instance.visible = true
	mesh_instance_2.visible = false
	
func get_projectile_damage(_target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[4]: # have shield, return normal
		return attack_damage
	
	if enemy_squad_attribute[1] in [1, 2]: # two handed or spear
		return attack_damage + int(attack_damage * bonus_damage)
		
	return attack_damage
