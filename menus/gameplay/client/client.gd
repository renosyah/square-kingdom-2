extends BaseGameplay

func _on_all_player_ready():
	._on_all_player_ready()
	
	yield(get_tree().create_timer(1),"timeout")
	
	spawn_squads(Global.prepare_army(
		Global.current_army, player_spawn_points[current_player.player_id], current_player, tile_map
	))
	
	for p in bot_players:
		var armies = Global.prepare_army(
			Global.bot_player_armies[p.player_id],
			player_spawn_points[p.player_id],
			p, tile_map, true
		)
