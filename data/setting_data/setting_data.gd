extends BaseData
class_name SettingData

# volume
export var music :float = 0.8
export var sfx :float = 0.7
export var voice :float = 0.8
export var mute :bool = false

# graphic 
export var shadow_type :int = 1
export var enable_fog :bool = true
export var enable_tilt_shift :bool = true

func from_dictionary(_data : Dictionary):
	.from_dictionary(_data)
	music = _data["a"]
	sfx = _data["b"]
	voice = _data["c"]
	mute = _data["c1"]
	shadow_type = _data["d"]
	enable_fog = _data["e"]
	enable_tilt_shift = _data["f"]
	
func to_dictionary() -> Dictionary :
	var _data :Dictionary = .to_dictionary()
	_data["a"] = music
	_data["b"] = sfx
	_data["c"] = voice
	_data["c1"] = mute
	_data["d"] = shadow_type
	_data["e"] = enable_fog
	_data["f"] = enable_tilt_shift
	return _data
