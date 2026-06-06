extends Node
class_name TileIndex

enum {ground,mud,road,sand,water,trees,rocks,rotates}

const tile_names = {
	ground :0,
	mud :1,
	road :2,
	sand :3,
	water :4,
	trees :[5,6,7,8],
	rocks :[9,10,11],
	rotates :[0,1,2]
}

const tiles = [
	preload("res://scenes/tiles/ground.tscn"),
	preload("res://scenes/tiles/mud.tscn"),
	preload("res://scenes/tiles/road.tscn"),
	preload("res://scenes/tiles/sand.tscn"),
	preload("res://scenes/tiles/water.tscn"),
	
	preload("res://scenes/tiles/tree_1.tscn"),
	preload("res://scenes/tiles/tree_2.tscn"),
	preload("res://scenes/tiles/tree_3.tscn"),
	preload("res://scenes/tiles/tree_4.tscn"),
	
	preload("res://scenes/tiles/rock_1.tscn"),
	preload("res://scenes/tiles/rock_2.tscn"),
	preload("res://scenes/tiles/rock_3.tscn"),
]

const tiles2d = [
	preload("res://assets/user_interface/minimap/tile_2d/ground.tscn"),
	preload("res://assets/user_interface/minimap/tile_2d/mud.tscn"),
	preload("res://assets/user_interface/minimap/tile_2d/road.tscn"),
	preload("res://assets/user_interface/minimap/tile_2d/sand.tscn"),
	preload("res://assets/user_interface/minimap/tile_2d/sea.tscn"),
	
	preload("res://assets/user_interface/minimap/tile_2d/tree.tscn"),
	preload("res://assets/user_interface/minimap/tile_2d/tree.tscn"),
	preload("res://assets/user_interface/minimap/tile_2d/tree.tscn"),
	preload("res://assets/user_interface/minimap/tile_2d/tree.tscn"),
	
	preload("res://assets/user_interface/minimap/tile_2d/rock.tscn"),
	preload("res://assets/user_interface/minimap/tile_2d/rock.tscn"),
	preload("res://assets/user_interface/minimap/tile_2d/rock.tscn"),
]

static func generate_spawn_points(map_size :int) -> Array:
	var datas :Array = []
	var spawn_points_offset :Array = get_spawn_points(map_size, 3)
	
	for offset in spawn_points_offset:
		datas.append_array(generate_player_spawn_tiles(offset))
		
	return datas
	
static func generate_player_spawn_tiles(offset :Vector2) -> Array:
	var spawn_points :Array = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(), Vector2.ZERO, 2
	) + [Vector2.ZERO]
	
	for idx in spawn_points.size():
		spawn_points[idx] += offset
		
	return spawn_points
	
# will return center position of 
# each spawn point reserved tile
static func get_spawn_points(map_size :int, point_size :int) -> Array:
	return [
		Vector2.ZERO + Vector2.UP * (map_size - point_size),
		Vector2.ZERO + Vector2.LEFT * (map_size - point_size),
		Vector2.ZERO + Vector2.RIGHT * (map_size - point_size),
		Vector2.ZERO + Vector2.DOWN * (map_size - point_size),
		Vector2.ZERO
	]
