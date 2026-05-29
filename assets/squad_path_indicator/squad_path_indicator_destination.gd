extends Spatial

export var material :SpatialMaterial
export var squad_icon :StreamTexture

onready var mesh_instance = $MeshInstance
onready var sprite_3d = $Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh_instance.set_surface_material(0, material)
	sprite_3d.texture = squad_icon
