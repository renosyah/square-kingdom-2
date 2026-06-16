extends BaseTile

onready var mesh_instance = $MeshInstance
onready var rock = $MeshInstance/rock

var _v_notifier :VisibilityNotifier

func _ready():
	match (biom):
		0:
			mesh_instance.set_surface_material(0, preload("res://scenes/tiles/materials/grass_material.tres"))
			rock.set_surface_material(0, preload("res://scenes/tiles/materials/rock_material.tres"))
		1:
			mesh_instance.set_surface_material(0, preload("res://scenes/tiles/materials/desert.tres"))
			rock.set_surface_material(0, preload("res://scenes/tiles/materials/desert_rock.tres"))
		2:
			mesh_instance.set_surface_material(0, preload("res://scenes/tiles/materials/snow.tres"))
			rock.set_surface_material(0, preload("res://scenes/tiles/materials/snow_rock.tres"))
	
	_v_notifier = VisibilityNotifier.new()
	_v_notifier.aabb = AABB(Vector3.ONE * -0.5, Vector3.ONE)
	_v_notifier.max_distance = 12
	_v_notifier.connect("camera_entered", self, "_on_VisibilityNotifier_camera_entered")
	_v_notifier.connect("camera_exited", self, "_on_VisibilityNotifier_camera_exited")
	add_child(_v_notifier)
	
	yield(get_tree(),"idle_frame")
	rock.visible = _v_notifier.is_on_screen()
	
func _on_VisibilityNotifier_camera_entered(camera):
	rock.visible = true

func _on_VisibilityNotifier_camera_exited(camera):
	rock.visible = false
