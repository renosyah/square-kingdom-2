extends BaseGameplay

const squad_scenes = [
	preload("res://data/squad_data/archer.tres"),
	preload("res://data/squad_data/swordman.tres"),
	preload("res://data/squad_data/spearman.tres")
]

var _squad :BaseSquad

onready var bot_spawner_timer = $bot_spawner_timer

func _on_tile_map_ready():
	._on_tile_map_ready()
	
	spawn_player_squad()
	bot_spawner_timer.start()
	
func spawn_player_squad():
	var data :SquadData = squad_scenes.pick_random().duplicate()
	data.network_id = 1
	data.player_id = "player"
	data.node_name = "squad_1"
	data.current_tile = player_spawn_point
	data.pos = tile_map.get_tile(player_spawn_point).pos
	data.member_hp = 1000
	data.member_max_hp = 1000
	data.color_idx = player.color_idx
	data.team = 1
	spawn_squad(data)
	
func _on_squad_spawned(squad :BaseSquad):
	._on_squad_spawned(squad)
	
	if squad.player_id == "bot":
		squad.chase_enemy = _squad
		squad.chase_target()
		return
	
	_squad = squad
	
func _on_unit_dead(squad):
	._on_unit_dead(squad)
	
	if squad == _squad:
		spawn_player_squad()
	
func _on_floor_clicked(pos :Vector3):
	._on_floor_clicked(pos)
	
	var tile = tile_map.get_closes_tile(pos)
	if _squad:
		_squad.move_to(tile.id)


func _on_bot_spawner_timer_timeout():
	bot_spawner_timer.start()
	
	if squads.size() > 4:
		return
	
	var data :SquadData = squad_scenes.pick_random().duplicate()
	data.network_id = 1
	data.player_id = "bot"
	data.node_name = Utils.create_unique_id()
	data.current_tile = Vector2.ZERO
	data.pos = Vector3.ZERO
	data.member_hp = 100
	data.member_max_hp = 100
	data.color_idx = 0
	data.team = 2
	spawn_squad(data)








