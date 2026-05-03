extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var editable_tile_map = $editable_tile_map

var nav :NavTileMap
var tile_highlights :Array = []
var map_data :TileMapFileData

func _ready():
	ui.movable_camera_ui.target = movable_camera
	
	map_data = TileMapUtils.generate_empty_tile_map(8)
	TileMapUtils.randomize_map_data(map_data)
	
	editable_tile_map.load_data_map(map_data, true)

func _on_editable_tile_map_on_map_ready():
	nav = editable_tile_map.get_nav_tile_map()
	
	for i in map_data.navigations[0]:
		var nav :NavigationData = i
		var h = preload("res://assets/tile_highlight/tile_highlight.tscn").instance()
		add_child(h)
		h.enable(nav.enable)
		h.translation = nav.pos * 1.02
		tile_highlights.append(h)
