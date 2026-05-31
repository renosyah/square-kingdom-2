extends Spatial

export var material :SpatialMaterial
onready var mesh_instance = $MeshInstance
onready var mesh_instance_2 = $MeshInstance2

func _ready():
	mesh_instance.set_surface_material(1, material)
	mesh_instance_2.set_surface_material(1, material)
