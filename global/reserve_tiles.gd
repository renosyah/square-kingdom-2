extends Node
class_name ReserveTile

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
