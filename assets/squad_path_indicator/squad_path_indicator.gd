extends Spatial

export var material :SpatialMaterial
onready var mesh_instance = $MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh_instance.set_surface_material(0, material)

