extends Spatial

export var material :SpatialMaterial

onready var mesh_instance = $MeshInstance
onready var door = $door
onready var door_2 = $Spatial/door2

func _ready():
	mesh_instance.set_surface_material(1, material)
	door.set_surface_material(1, material)
	door_2.set_surface_material(1, material)
