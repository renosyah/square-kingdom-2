extends BaseTile

onready var mesh_instance = $MeshInstance

func _ready():
	match (biom):
		0:
			mesh_instance.set_surface_material(0, preload("res://scenes/tiles/materials/grass_material.tres"))
		1:
			mesh_instance.set_surface_material(0, preload("res://scenes/tiles/materials/desert.tres"))
		2:
			mesh_instance.set_surface_material(0, preload("res://scenes/tiles/materials/snow.tres"))
