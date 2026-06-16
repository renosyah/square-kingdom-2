extends BaseTile

onready var mesh_instance = $MeshInstance
onready var tree_tropic = $MeshInstance/tree_tropic
onready var tree_desert = $MeshInstance/tree_desert
onready var tree_snow = $MeshInstance/tree_snow

var target :MeshInstance

var _v_notifier :VisibilityNotifier

func _ready():
	tree_tropic.visible = false
	tree_desert.visible = false
	tree_snow.visible = false

	match (biom):
		0:
			mesh_instance.set_surface_material(0, preload("res://scenes/tiles/materials/grass_material.tres"))
			target = tree_tropic
		1:
			mesh_instance.set_surface_material(0, preload("res://scenes/tiles/materials/desert.tres"))
			target = tree_desert
		2:
			mesh_instance.set_surface_material(0, preload("res://scenes/tiles/materials/snow.tres"))
			target = tree_snow
			
	_v_notifier = VisibilityNotifier.new()
	_v_notifier.aabb = AABB(Vector3.ONE * -0.5, Vector3.ONE)
	_v_notifier.max_distance = 12
	_v_notifier.connect("camera_entered", self, "_on_VisibilityNotifier_camera_entered")
	_v_notifier.connect("camera_exited", self, "_on_VisibilityNotifier_camera_exited")
	add_child(_v_notifier)
	
	yield(get_tree(),"idle_frame")
	target.visible = _v_notifier.is_on_screen()
	
func _on_VisibilityNotifier_camera_entered(camera):
	target.visible = true

func _on_VisibilityNotifier_camera_exited(camera):
	target.visible = false
