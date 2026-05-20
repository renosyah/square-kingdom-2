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
	
