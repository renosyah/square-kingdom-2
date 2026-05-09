extends Node2D
class_name Tile2D

export var tile_rotation_degree :float
export var target_image :NodePath

onready var _target_image :TextureRect = get_node_or_null(target_image)

func _ready():
	set_process(false)
	set_physics_process(false)
	
	if _target_image:
		_target_image.rect_rotation = tile_rotation_degree
