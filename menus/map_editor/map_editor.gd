extends Node

onready var ui = $ui
onready var movable_camera = $movable_camera
onready var editable_tile_map = $editable_tile_map
onready var clickable_floor = $clickable_floor
onready var highlights = $highlights

var nav :NavTileMap
var tile_highlights :Array = []

func _ready():
	ui.movable_camera_ui.target = movable_camera
	editable_tile_map.load_data_map(Global.current_tile_map_file_data, true)

func _process(delta):
	var pos = movable_camera.translation * Vector3(1,0,1)
	clickable_floor.translation = pos
	ui.minimap.rotation_rad = movable_camera.rotation.y
	ui.minimap.offset = Vector2(pos.x, pos.z) * 15
	
func _on_editable_tile_map_on_map_ready():
	nav = editable_tile_map.get_nav_tile_map()
	
	for i in Global.current_tile_map_file_data.navigations[0]:
		var n :NavigationData = i
		var h = preload("res://assets/tile_highlight/tile_highlight.tscn").instance()
		highlights.add_child(h)
		h.enable(n.enable)
		h.translation = n.pos * 1.02
		tile_highlights.append(h)

func _on_clickable_floor_on_floor_clicked(pos):
	var tile :TileMapData = editable_tile_map.get_closes_tile(pos)
