extends Node

func _ready():
	SaveLoad.ensure_dir("user://%s/" % map_dir)
	
	setup_transition()
	load_player_data()
	setup_tick()
	
##########################################  tick  ############################################

signal on_global_tick

var _tick :Timer

func setup_tick():
	_tick = Timer.new()
	_tick.wait_time = 1
	_tick.one_shot = true
	_tick.connect("timeout", self, "_on_tick")
	add_child(_tick)
	_tick.start()
	
func _on_tick():
	emit_signal("on_global_tick")
	_tick.start()
	
##########################################  player data  ############################################

const player_data_filepath :String = "player_data.dat"
var player_data :PlayerData

func monitor_network():
	Network.connect("server_player_connected", self, "_on_player_connected")
	Network.connect("client_player_connected", self, "_on_player_connected")
	
func _on_player_connected(player_network_unique_id :int):
	player_data.player_network_id = player_network_unique_id

func load_player_data():

	player_data = PlayerData.new()
	var data = SaveLoad.load_save(player_data_filepath, true)
	if data == null:
		player_data.player_id = Utils.create_unique_id()
		player_data.player_name = OS.get_name()
		player_data.player_rank = 0
		player_data.player_team = 1
		player_data.player_potrait = 0
		SaveLoad.save(player_data_filepath, player_data.to_dictionary(), true)
		
	else:
		player_data.from_dictionary(data)
		
##########################################  map editor  ############################################
# for load and save maps
const map_dir = "map"

##########################################  transisiion  ############################################
var transition :CanvasLayer

func setup_transition():
	transition = preload("res://assets/transision_screen/transision_screen.tscn").instance()
	add_child(transition)
	
func change_scene(scene :String, use :bool = false, bg_idx :int = 0):
	transition.change_scene(scene, use, bg_idx)
	
func hide_transition():
	transition.hide_transition()
