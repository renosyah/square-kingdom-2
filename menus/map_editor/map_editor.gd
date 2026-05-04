extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var editable_tile_map = $editable_tile_map
onready var clickable_floor = $clickable_floor

var nav :NavTileMap
var tile_highlights :Array = []

func _ready():
	ui.movable_camera_ui.target = movable_camera
	Global.current_tile_map_file_data = TileMapUtils.generate_empty_tile_map(8)
	#TileMapUtils.randomize_map_data(Global.current_tile_map_file_data)
	editable_tile_map.load_data_map(Global.current_tile_map_file_data, true)

func _process(delta):
	clickable_floor.translation = movable_camera.translation * Vector3(1,0,1)

func _on_editable_tile_map_on_map_ready():
	nav = editable_tile_map.get_nav_tile_map()
	
#	for i in map_data.navigations[0]:
#		var n :NavigationData = i
#		var h = preload("res://assets/tile_highlight/tile_highlight.tscn").instance()
#		add_child(h)
#		h.enable(n.enable)
#		h.translation = n.pos * 1.02
#		tile_highlights.append(h)

func _on_clickable_floor_on_floor_clicked(pos):
	var tile :TileMapData = editable_tile_map.get_closes_tile(pos)
