extends MeleeWeapon

export var icon :StreamTexture
export var material :SpatialMaterial
onready var mesh_instance = $MeshInstance

func _ready():
	mesh_instance.set_surface_material(3, material)
