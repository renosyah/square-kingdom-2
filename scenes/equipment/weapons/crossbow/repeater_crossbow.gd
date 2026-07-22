extends RangeWeapon

onready var mesh_instance = $MeshInstance
onready var mesh_instance_2 = $MeshInstance2
onready var timer = $Timer

func _ready():
	mesh_instance.visible = true
	mesh_instance_2.visible = false
	
func shot_projectile(target_tile :Vector2, dmg :int, to :Vector3, v :bool):
	var count :int = int(rand_range(2,4))
	for _i in count:
		.shot_projectile(target_tile, dmg, to, v)
		
		mesh_instance.visible = false
		mesh_instance_2.visible = true
		
		timer.start()
		yield(timer,"timeout")
		
		mesh_instance.visible = true
		mesh_instance_2.visible = false
	
func get_projectile_damage(_target, enemy_squad_attribute :Array) -> int:
	return attack_damage + int(attack_damage * bonus_damage)
