extends BaseData
class_name SettingData

# gameplay
export var camera_move_speed :float = 0.018 # 0.008 - 0.040
export var camera_zoom_speed :float = 0.02 # 0.01 - 0.03
export var camera_rotation_speed :float = 45.0 # 20 - 90
export var unselect_on_command :bool = false
export var show_unit_tile :bool = false

# volume
export var music :float = 0.8
export var sfx :float = 0.7
export var voice :float = 0.8
export var mute :bool = false

# graphic 
export var shadow_type :int = 1
export var enable_fog :bool = true
export var enable_tilt_shift :bool = true
export var light :float = 1

func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	music = _data["a"]
	sfx = _data["b"]
	voice = _data["c"]
	mute = _data["c1"]
	shadow_type = _data["d"]
	enable_fog = _data["e"]
	enable_tilt_shift = _data["f"]
	light = _data["g"]
	camera_move_speed = _data["h"]
	camera_zoom_speed = _data["i"]
	camera_rotation_speed = _data["j"]
	unselect_on_command = _data["k"]
	show_unit_tile = _data["l"]

func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["a"] = music
	_data["b"] = sfx
	_data["c"] = voice
	_data["c1"] = mute
	_data["d"] = shadow_type
	_data["e"] = enable_fog
	_data["f"] = enable_tilt_shift
	_data["g"] = light
	_data["h"] = camera_move_speed
	_data["i"] = camera_zoom_speed
	_data["j"] = camera_rotation_speed
	_data["k"] = unselect_on_command
	_data["l"] = show_unit_tile
	return _data
