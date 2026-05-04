extends Node
class_name TileMapUtils

const ARROW_DIRECTIONS = [
	Vector2.UP, Vector2.DOWN, 
	Vector2.LEFT, Vector2.RIGHT,
]

const DIAGONAL_DIRECTIONS = [
	Vector2.UP + Vector2.LEFT,
	Vector2.UP + Vector2.RIGHT,
	Vector2.DOWN + Vector2.LEFT,
	Vector2.DOWN + Vector2.RIGHT,
]

# size is range of tile map
# for example : 
# 2 → 5 × 5
# 4 → 9 × 9
# 6 → 13 × 13
# 8 → 17 × 17
static func generate_empty_tile_map(size :int) -> TileMapFileData:
	var tiles = get_adjacent_tiles(get_directions(), Vector2.ZERO, size)
	tiles.push_front(Vector2.ZERO)
	
	var tile_datas = []
	var navigations = []
	var tile_ids = {}
	var objects = []
	
	for id in tiles:
		var data :TileMapData = TileMapData.new()
		data.id = id
		data.pos = Vector3(id.x, 0, id.y)
		data.scene_idx = 0
		data.rotation_idx = 0
		tile_datas.append(data)
		
		var nav_id = tile_datas.size()
		tile_ids[id] = nav_id
		
	for tile_data in tile_datas:
		var nav_data :NavigationData = NavigationData.new()
		nav_data.id = tile_data.id
		nav_data.pos = tile_data.pos
		nav_data.navigation_id = tile_ids[tile_data.id]
		nav_data.enable = true
		nav_data.neighbors = []
		
		var _tiles = get_adjacent_tiles(get_directions(), tile_data.id)
		for i in _tiles:
			if tile_ids.has(i):
				nav_data.neighbors.append(tile_ids[i])
				
		navigations.append(nav_data)
		
	var map_data :TileMapFileData = TileMapFileData.new()
	map_data.tiles = tile_datas
	map_data.tile_ids = tile_ids
	map_data.navigations[0] = navigations
	
	return map_data
	
# return all adjacent tiles
# with range and type of direction
# only returned tile that registered in Astar navigation
static func get_astar_adjacent_tile(nav :AStar2D, navigation_id: int, radius: int = 1, blocked_nav_ids :Array = []) -> Array:
	var visited := {}
	var result := []
	var queue := [navigation_id]
	visited[navigation_id] = 0
	
	while not queue.empty():
		var current_id = queue.pop_front()
		var current_depth = visited[current_id]
		
		if current_depth >= radius:
			continue
			
		for neighbor_id in nav.get_point_connections(current_id):
			if neighbor_id in visited:
				continue
				
			if nav.is_point_disabled(neighbor_id):
				continue
				
			if blocked_nav_ids.has(neighbor_id):
				continue
				
			visited[neighbor_id] = current_depth + 1
			queue.append(neighbor_id)
			result.append(nav.get_point_position(neighbor_id))
			
	visited.clear()
	queue.clear()
	
	return result # [Vector2]
	
static func tile_faced(direction :Vector2) -> Vector2:
	var dirs :Array = get_directions()
	var faced :Vector2 = dirs[0]
	for i in dirs:
		if i == faced:
			continue
			
		var dis1 :float = direction.distance_squared_to(i) 
		var dis2 :float = direction.distance_squared_to(faced) 
		if dis1 < dis2:
			faced = i
		
	return faced
	
# return all adjacent tiles
# with range and type of direction
static func get_adjacent_tiles(directions :Array, from: Vector2 = Vector2.ZERO, radius: int = 1) -> Array:
	var visited := {}
	var frontier := [from]
	visited[from] = true
	
	for _step in range(radius):
		var next_frontier := []
		for current in frontier:
			for dir in directions:
				var neighbor = current + dir
				if not visited.has(neighbor):
					visited[neighbor] = true
					next_frontier.append(neighbor)
		frontier = next_frontier
		
	# just remove from
	visited.erase(from)
	
	var tiles :Array = visited.keys().duplicate()
	visited.clear()
	
	return tiles # [Vector2]
	
static func get_directions() -> Array:
	return ARROW_DIRECTIONS + DIAGONAL_DIRECTIONS
	
