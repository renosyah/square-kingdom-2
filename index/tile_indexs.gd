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

static func generate_spawn_points(map_size :int, range_size :int = 2, edge_offset :int = 3) -> Array:
	var datas :Array = []
	var spawn_points_offset :Array = get_spawn_points(map_size, edge_offset)
	
	for offset in spawn_points_offset:
		datas.append_array(generate_player_spawn_tiles(offset, range_size))
		
	return datas
	
static func generate_player_spawn_tiles(offset :Vector2, range_size :int) -> Array:
	var spawn_points :Array = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(), Vector2.ZERO, range_size
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
	

static func generate_fort_ring(tile_id: Vector2, size: int = 2) -> Array:
	var result = []

	var min_x = tile_id.x - size
	var max_x = tile_id.x + size
	var min_y = tile_id.y - size
	var max_y = tile_id.y + size

	var side_len = (size * 2) + 1

	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):

			# skip inner area, only keep outer ring
			if x != min_x and x != max_x and y != min_y and y != max_y:
				continue

			var pos = Vector2(x, y)

			var is_corner = (
				(x == min_x and y == min_y) or
				(x == min_x and y == max_y) or
				(x == max_x and y == min_y) or
				(x == max_x and y == max_y)
			)

			var is_gate = false
			var t_type = "wall"
			var rot = 0
			var outsides = []

			# OUTSIDE TILE CALC
			# outward direction depends on which edge it is on
			if y == min_y:
				outsides.append(pos + Vector2.UP)
				rot = 0
			elif y == max_y:
				outsides.append(pos + Vector2.DOWN)
				rot = 180
			elif x == min_x:
				outsides.append(pos + Vector2.LEFT)
				rot = 90
			elif x == max_x:
				outsides.append(pos + Vector2.RIGHT)
				rot = -90

			# CORNERS → 2 outside tiles (diagonal outward)
			if is_corner:
				t_type = "corner"
				outsides = []

				if x == min_x and y == min_y:
					rot = 0
					outsides = [pos + Vector2.LEFT, pos + Vector2.UP]
				elif x == max_x and y == min_y:
					rot = -90
					outsides = [pos + Vector2.RIGHT, pos + Vector2.UP]
				elif x == max_x and y == max_y:
					rot = 180
					outsides = [pos + Vector2.RIGHT, pos + Vector2.DOWN]
				elif x == min_x and y == max_y:
					rot = 90
					outsides = [pos + Vector2.LEFT, pos + Vector2.DOWN]

			# GATES (1 per side, centered)
			else:
				var mid = tile_id

				if y == min_y and x == mid.x:
					is_gate = true
					t_type = "gate"
				elif y == max_y and x == mid.x:
					is_gate = true
					t_type = "gate"
				elif x == min_x and y == mid.y:
					is_gate = true
					t_type = "gate"
				elif x == max_x and y == mid.y:
					is_gate = true
					t_type = "gate"
					
			result.append({
					"tile_id": pos,
					"type": t_type,
					"rotation": rot,
					"outsides": outsides
				})
				
	return result
