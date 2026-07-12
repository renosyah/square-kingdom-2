extends MeleeWeapon

export var banner_icon :StreamTexture
export var material :SpatialMaterial

onready var mesh_instance = $MeshInstance
onready var sprite_3d = $Sprite3D

func _ready():
	mesh_instance.set_surface_material(3, material)
	sprite_3d.texture = banner_icon
