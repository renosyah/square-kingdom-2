extends InfantrySquad
class_name SiegeEngineSquad

const push_siege_engines = [
	preload("res://assets/sounds/walks/engine_walk_1.wav"),
	preload("res://assets/sounds/walks/engine_walk_2.wav"),
	preload("res://assets/sounds/walks/engine_walk_3.wav"),
	preload("res://assets/sounds/walks/engine_walk_4.wav"),
	preload("res://assets/sounds/walks/engine_walk_5.wav")
]

const siege_breaks = [
	preload("res://assets/sounds/sfx/siege_break_1.wav"),
	preload("res://assets/sounds/sfx/siege_break_2.wav"),
	preload("res://assets/sounds/sfx/siege_break_3.wav"),
	preload("res://assets/sounds/sfx/siege_break_4.wav"),
	preload("res://assets/sounds/sfx/siege_break_5.wav")
]

export var siege_engine_scene :PackedScene
export var minimum_range :int = 2

var _minimum_range_tiles :Array = []
var _siege_engine :SiegeEngine
var _siege_engine_audio :AudioStreamPlayer3D

func _ready():
	_siege_engine_audio = AudioStreamPlayer3D.new()
	_siege_engine_audio.bus = Global.bus_sfx
	_siege_engine_audio.unit_db = 5
	add_child(_siege_engine_audio)
	
func _init_formations():
	#._init_formations()
	
	# Vector3.ZERO is reserve for siege engine
	_formation_offsets = [
		Vector3.ZERO + Vector3.LEFT,  Vector3.ZERO + Vector3.RIGHT
	]
	_formation_positions = _formation_offsets.duplicate()
	
func _spawn_members():
	_siege_engine = siege_engine_scene.instance()
	_siege_engine.connect("on_set_damage_to_tile", self, "_on_set_damage_to_tile")
	_siege_engine.squad = self
	add_child(_siege_engine)
	_siege_engine.set_as_toplevel(true)
	_siege_engine.translation = global_position
	
	._spawn_members()
	
func _on_set_damage_to_tile(_engine :SiegeEngine, center_tile_id :Vector2, attack_damage :int):
	if not _is_master:
		return
		
	# catapult deal AOE damage
	var tiles :Array = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(), center_tile_id, 1
	) + [center_tile_id]
	
	for tile_id in tiles:
		if not unit_position.has(tile_id):
			continue
			
		var unit_positions :Array = unit_position[tile_id]
		if unit_positions.empty():
			continue
			
		var dmg = attack_damage
		if tile_id != center_tile_id:
			dmg = attack_damage * 0.5 # half damage forsurounded
			
		_splash_damage(unit_positions, dmg)
	
func _splash_damage(unit_positions:Array, dmg :int):
	for enemy_squad in unit_positions:
		if not is_instance_valid(enemy_squad):
			continue
			
		var members :Array = enemy_squad.get_members()
		if members.empty():
			continue
			
		# set damage to random member
		var t = randi() % members.size()
		t = int(clamp(t, 1, members.size()))
		
		for _i in t:
			var idx :int = enemy_squad.get_member_index(members.pick_random())
			enemy_squad.take_damage(dmg, idx, get_path())
		
func _on_walking(delta :float):
	if visible and _is_moving and _walk_timer.is_stopped():
		_walk_timer.wait_time = 0.5
		_walk_timer.start()
		_step_audio.stream = push_siege_engines.pick_random()
		_step_audio.play()
			
func _ajust_formation(pos :Vector3, delta :float):
	._ajust_formation(pos, delta)
	
	if is_dead or not _member_spawned:
		return
		
	if _siege_engine.iddle:
		_siege_engine.translation = _siege_engine.translation.linear_interpolate(pos, 5 * delta)
		
func _perform_range_attack():
	#._perform_range_attack()
	
	var conditions = [is_dead, not _member_spawned, not can_attack, not _has_enemy]
	if  conditions.has(true):
		return
		
	if _range_attack_timer.is_stopped():
		_range_attack_timer.start()
		
		_range_engagement = true
		_melee_engagement = false
		
		_siege_engine.tile_target = enemy.current_tile
		_siege_engine.target_position = enemy.global_position
		_siege_engine.attack()

func update_spotting():
	.update_spotting()
	
	_minimum_range_tiles = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.ARROW_DIRECTIONS, current_tile, minimum_range
	)
	
	# too close
	# cant do shit
	# remove min ramge from ranges
	for id in _minimum_range_tiles:
		_attack_tile_ranges.erase(id)
		
func _is_in_ranges(target) -> bool:
	if _is_in_attack_range(target):
		return true
		
	return _is_in_melee_range(target)
	
func on_dead():
	if visible:
		_siege_engine_audio.stream = siege_breaks.pick_random()
		_siege_engine_audio.play()
		yield(_siege_engine_audio,"finished")
		yield(get_tree().create_timer(1),"timeout")
		
	.on_dead()
























