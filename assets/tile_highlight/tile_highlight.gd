extends Spatial

const nav = preload("res://assets/tile_highlight/allow_nav_material.tres")
const no_nav = preload("res://assets/tile_highlight/blocked_nav_material.tres")

onready var mesh_instance = $MeshInstance

func enable(v :bool):
	mesh_instance.set_surface_material(0, nav if v else no_nav)
