extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera

# Called when the node enters the scene tree for the first time.
func _ready():
	ui.movable_camera_minimap.target = movable_camera
	ui.movable_camera_minimap.center_pos = Vector3.ZERO

func _process(delta):
	var pos = movable_camera.translation * Vector3(1,0,1)
	ui.minimap.rotation_rad = movable_camera.rotation.y
	ui.minimap.offset = Vector2(pos.x, pos.z) * 10
