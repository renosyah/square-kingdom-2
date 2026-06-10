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
	
func get_attack_damage(enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[2] == 2: # using bow/crossbow
		return attack_damage * bonus_damage
		
	return attack_damage
