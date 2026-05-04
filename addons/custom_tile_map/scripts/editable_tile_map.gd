extends Spatial
class_name EditableTileMap

signal on_map_ready
signal on_tile_updated(id, data, node)

# must be set with BaseTile scenes
# and make sure index were set accordingly
export (Array, PackedScene) var tile_scenes :Array

var _spawned_tiles :Dictionary = {} # { Vector2 : BaseTile }
var _tile_map_data :TileMapFileData
var _is_editor :bool = false
onready var _nav_tile_map :NavTileMap = $nav_tile_map

func _ready():
	set_process(false)
	set_physics_process(false)

func load_data_map(data: TileMapFileData, is_editor:bool = false):
	_clean()
	
	_is_editor = is_editor
	_tile_map_data = data
	
	_spawn_tiles()
	
	yield(get_tree(),"idle_frame")
	emit_signal("on_map_ready")
	
func export_data() -> TileMapFileData:
	return _tile_map_data
	
func get_nav_tile_map() -> NavTileMap:
	return _nav_tile_map
	
func get_tiles_instances() -> Array:
	return _spawned_tiles.values() # [ BaseTile ]
	
func has_tile(id :Vector2) -> bool:
	return _spawned_tiles.has(id)
	
func get_tile_instance(id :Vector2) -> BaseTile:
	if not _spawned_tiles.has(id):
		return null
		
	return _spawned_tiles[id] # BaseTile
	
func update_spawned_tile(data :TileMapData):
	var _spawned_tile :BaseTile = _spawned_tiles[data.id]
	
	# remove old
	_spawned_tile.queue_free()
	_spawned_tiles.erase(data.id)
	
	# spawn new
	var tile :BaseTile = _spawn_tile(data)
	tile.visible = true
	_spawned_tiles[data.id] = tile
	
	# update to _tile_map_data
	if _is_editor:
		var pos = 0
		for i in _tile_map_data.tiles:
			var x :TileMapData = i
			if x.id == data.id:
				_tile_map_data.tiles[pos] = data
				break
				
			pos += 1
			
	emit_signal("on_tile_updated", data.id, data, tile)
	
func get_closes_tile_instance(from :Vector3) -> BaseTile:
	var tiles :Array = get_tiles_instances()
	if tiles.empty():
		return null
		
	var current :BaseTile = tiles[0]
	for i in tiles:
		if i == current:
			continue

		var dist_1 = current.global_position.distance_squared_to(from)
		var dist_2 = i.global_position.distance_squared_to(from)
		if dist_2 < dist_1:
			current = i
			
	return current # BaseTile
	
func get_closes_tile(from :Vector3) -> TileMapData:
	var tiles :Array = _tile_map_data.tiles
	if tiles.empty():
		return null
		
	var current :TileMapData = tiles[0]
	var modifier :Vector3 = global_position
	for i in tiles:
		if i == current:
			continue
			
		var dist_1 = (current.pos + modifier).distance_squared_to(from)
		var dist_2 = (i.pos + modifier).distance_squared_to(from)
		if dist_2 < dist_1:
			current = i
			
	return current # TileMapData
	
func _spawn_tiles():
	for i in _tile_map_data.tiles:
		var data :TileMapData = i
		_spawned_tiles[data.id] = _spawn_tile(data)
	
func _spawn_tile(data :TileMapData) -> BaseTile:
	var tile :BaseTile = tile_scenes[data.scene_idx].instance()
	tile.name = 'tile_%s' % data.id
	add_child(tile)
	tile.translation = global_position + data.pos
	
	if _is_editor:
		tile.translation.x = tile.translation.x * 1.02
		tile.translation.z = tile.translation.z * 1.02
		
	return tile

func _ids_to_tile_nodes(ids :Array) -> Array:
	var datas = []
	for i in ids:
		datas.append(get_tile_instance(i))
	return datas
	
func _clean():
	for key in _spawned_tiles.keys():
		var tile :BaseTile = _spawned_tiles[key]
		tile.queue_free()
		
	_spawned_tiles.clear()

