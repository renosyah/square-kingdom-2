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
	preload("res://scenes/minimap/tile_2d/ground.tscn"),
	preload("res://scenes/minimap/tile_2d/mud.tscn"),
	preload("res://scenes/minimap/tile_2d/road.tscn"),
	preload("res://scenes/minimap/tile_2d/sand.tscn"),
	preload("res://scenes/minimap/tile_2d/sea.tscn"),
	
	preload("res://scenes/minimap/tile_2d/tree.tscn"),
	preload("res://scenes/minimap/tile_2d/tree.tscn"),
	preload("res://scenes/minimap/tile_2d/tree.tscn"),
	preload("res://scenes/minimap/tile_2d/tree.tscn"),
	
	preload("res://scenes/minimap/tile_2d/rock.tscn"),
	preload("res://scenes/minimap/tile_2d/rock.tscn"),
	preload("res://scenes/minimap/tile_2d/rock.tscn"),
]
