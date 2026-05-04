extends Resource
class_name TileMapFileData

var tile_ids :Dictionary # { Vector2: int }
var tiles : Array # [ TileMapData ]
var navigations : Dictionary # {int (LAYER_ID):[ NavigationData ]}

func from_dictionary(_data : Dictionary):
	tile_ids = _data["a"].duplicate() # { Vector2: int }
	
	tiles = [] # [ TileMapData ]
	for i in _data["b"]:
		var x :TileMapData = TileMapData.new()
		x.from_dictionary(i)
		tiles.append(x)
		
	navigations = {} # {int:[ NavigationData ]}
	for key in _data["c"].keys():
		navigations[key] = []
		
		for i in _data["c"][key]:
			var x :NavigationData = NavigationData.new()
			x.from_dictionary(i)
			navigations[key].append(x)
		
func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	_data["a"] = tile_ids.duplicate() # { Vector2: int }
	
	_data["b"] = [] # [ TileMapData ]
	for i in tiles:
		var x :TileMapData = i
		_data["b"].append(x.to_dictionary())
		
	_data["c"] = {} # {int:[ NavigationData ]}
	for key in navigations.keys():
		_data["c"] = []
		
		for i in navigations[key]:
			var x :NavigationData = i
			_data["c"].append(x.to_dictionary())
		
	return _data
	
func to_bytes() -> PoolByteArray:
	return var2bytes(to_dictionary())
	
func from_bytes(bytes :PoolByteArray):
	from_dictionary(bytes2var(bytes))
