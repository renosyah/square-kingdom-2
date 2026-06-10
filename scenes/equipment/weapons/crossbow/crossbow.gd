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
	
func get_attack_damage(enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[3] in [2,3]: # medium or heavy armor
		return attack_damage * bonus_damage
		
	return attack_damage
