extends Resource
class_name TileMapFileData

var tile_ids :Dictionary # { Vector2: int }
var tiles : Array # [ TileMapData ]
var navigations : Array # [(index as LAYER_ID) [ NavigationData ]]

func from_dictionary(_data : Dictionary):
	tile_ids = _data["a"].duplicate() # { Vector2: int }
	
	tiles = [] # [ TileMapData ]
	for i in _data["b"]:
		var x :TileMapData = TileMapData.new()
		x.from_dictionary(i)
		tiles.append(x)
		
	navigations = [] # [(index as LAYER_ID) [ NavigationData ]]
	for i in _data["c"]:
		var datas :Array = []
		for nav in i:
			var x :NavigationData = NavigationData.new()
			x.from_dictionary(nav)
			datas.append(x)
			
		navigations.append(datas)
		
func to_dictionary() -> Dictionary :
	var _data :Dictionary = {}
	_data["a"] = tile_ids.duplicate() # { Vector2: int }
	
	_data["b"] = [] # [ TileMapData ]
	for i in tiles:
		var x :TileMapData = i
		_data["b"].append(x.to_dictionary())
		
	_data["c"] = [] # [(index as LAYER_ID) [ NavigationData ]]
	for i in navigations:
		var datas :Array = []
		
		for nav in i:
			var x :NavigationData = nav
			datas.append(x.to_dictionary())
			
		_data["c"].append(datas)
		
	return _data
	
func to_bytes() -> PoolByteArray:
	return var2bytes(to_dictionary())
	
func from_bytes(bytes :PoolByteArray):
	from_dictionary(bytes2var(bytes))
