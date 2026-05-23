extends Node

onready var _directional_light = $DirectionalLight
onready var _world_environment = $WorldEnvironment

func _ready():
	_apply_setting(Global.setting_data)
	Global.connect("on_setting_updated", self, "_apply_setting")

func _apply_setting(d :SettingData):
	set_shadow_quality(d.shadow_type)
	enable_fog(d.enable_fog)
	enable_tilt_shift(d.enable_tilt_shift)
	set_light(d.light)

func set_light(v :float):
	_directional_light.light_energy = clamp(v , 0 ,1)

func set_shadow_quality(c :int):
	_directional_light.shadow_enabled = (c != 0)
	
	match c:
		1:
			_directional_light.directional_shadow_mode = DirectionalLight.SHADOW_ORTHOGONAL
		2:
			_directional_light.directional_shadow_mode = DirectionalLight.SHADOW_PARALLEL_2_SPLITS
		3:
			_directional_light.directional_shadow_mode = DirectionalLight.SHADOW_PARALLEL_3_SPLITS
		4:
			_directional_light.directional_shadow_mode = DirectionalLight.SHADOW_PARALLEL_4_SPLITS

func enable_fog(v :bool):
	_world_environment.environment.fog_enabled = v
	
func enable_tilt_shift(v :bool):
	_world_environment.environment.dof_blur_far_enabled = v
	_world_environment.environment.dof_blur_near_enabled = v
