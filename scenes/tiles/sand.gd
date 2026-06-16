extends BaseTile

onready var mesh_instance = $MeshInstance

func _ready():
	if biom == 2:
		mesh_instance.set_surface_material(0, preload("res://scenes/tiles/materials/snow.tres"))
