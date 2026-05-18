extends BaseGameplay

var _squad :BaseSquad

func _on_tile_map_ready():
	._on_tile_map_ready()
	
	var data :SquadData = preload("res://data/squad_data/swordman.tres")
	data.network_id = 1
	data.node_name = "squad_1"
	data.current_tile = Vector2.ZERO
	data.pos = Vector3.ZERO
	
	spawn_squad(data)
	
func _on_squad_spawned(squad):
	._on_squad_spawned(squad)
	
	_squad = squad
	_squad.nav = nav
	_squad.unit_position = tile_position_manager.get_positions()
	
func _on_floor_clicked(pos :Vector3):
	._on_floor_clicked(pos)
	
	var tile = tile_map.get_closes_tile(pos)
	if _squad:
		_squad.move_to(tile.id)
