extends Spatial

export var material :SpatialMaterial

onready var mesh_instance = $MeshInstance

func _ready():
	mesh_instance.set_surface_material(1, material)

func destroy():
	pass
