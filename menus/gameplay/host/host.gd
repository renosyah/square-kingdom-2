extends BaseGameplay

var bot_squads :Array

onready var bot_spawner_timer = $bot_spawner_timer

func _on_all_player_ready():
	._on_all_player_ready()
	
	yield(get_tree().create_timer(1),"timeout")
	
	spawn_squads(Global.prepare_army(player_spawn_point, tile_map))
	bot_spawner_timer.start()
	
func bot_attack_command(squad :BaseSquad, enemies :Array):
	if is_instance_valid(squad.enemy):
		return
		
	squad.attack_move = true
	squad.move_to(enemies.pick_random().current_tile)
	
func _on_squad_spawned(squad :BaseSquad, data :SquadData):
	._on_squad_spawned(squad, data)
	
	if squad.player_id == "bot":
		bot_squads.append(squad)
		
func _on_squad_member_dead(squad :BaseSquad, member):
	._on_squad_member_dead(squad, member)
	
	var attacked_by =  get_node(squad.attacked_by)
	ui.add_log("%s's (%s) member %s killed by %s (%s)" % [squad.unit_name, squad.player_id, member.name, attacked_by.unit_name, attacked_by.player_id])
	
func _on_squad_member_resurect(squad :BaseSquad, member):
	._on_squad_member_resurect(squad, member)
	
	ui.add_log("%s's (%s) member %s resurected" % [squad.unit_name, squad.player_id, member.name])
	
func _on_unit_dead(squad, data):
	._on_unit_dead(squad, data)
	
	var attacked_by = get_node(squad.attacked_by)
	ui.add_log("squad %s (%s) wiped by %s (%s)" % [squad.unit_name, squad.player_id, attacked_by.unit_name, attacked_by.player_id])

	if squad.player_id == "bot":
		bot_squads.erase(squad)
		
func _on_bot_spawner_timer_timeout():
	bot_spawner_timer.start()
	
	var enemies = []
	for i in squads:
		if i.player_id != "bot":
			enemies.append(i)
			
	if not enemies.empty():
		for i in bot_squads:
			bot_attack_command(i, enemies)
			
	# limit harashment
	if bot_squads.size() >= Global.players.size():
		return
	
	var data :SquadData = Global.template_squads.pick_random().duplicate()
	data.network_id = 1
	data.player_id = "bot"
	data.node_name = Utils.create_unique_id()
	data.current_tile = Vector2.ZERO
	data.pos = Vector3.ZERO
	data.color_idx = 1
	data.team = -1
	spawn_squad(data)








