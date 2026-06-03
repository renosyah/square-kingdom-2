extends BaseSquad
class_name CavalrySquad

signal on_cav_charge_buildup(squad, amount)
signal on_cav_charge(squad)

const walk_sounds = [
	preload("res://assets/sounds/walks/horse_step_1.wav"),
	preload("res://assets/sounds/walks/horse_step_2.wav"),
	preload("res://assets/sounds/walks/horse_step_3.wav"),
	preload("res://assets/sounds/walks/horse_step_4.wav")
]
const horse_dead = [
	preload("res://assets/sounds/death/horse_dead_1.wav"),
	preload("res://assets/sounds/death/horse_dead_2.wav"),
	preload("res://assets/sounds/death/horse_dead_3.wav")
]
const horse_skins = [
	preload("res://scenes/tile_units/squad_member/materials/horse_skin_1.tres"),
	preload("res://scenes/tile_units/squad_member/materials/horse_skin_2.tres"),
	preload("res://scenes/tile_units/squad_member/materials/horse_skin_3.tres")
]

export var charge_damage :int = 23
export var min_charge_required :int = 3

var _charges :int
var _horse_audio :AudioStreamPlayer3D

func _ready():
	_horse_audio = AudioStreamPlayer3D.new()
	_horse_audio.bus = Global.bus_sfx
	add_child(_horse_audio)
	
# override
func _spawn_members():
	#._spawn_members()
	
	member_alive = total_member
	
	# use network id so it persistence
	var _rng = RandomNumberGenerator.new()
	_rng.seed = network_id + member_max_hp
	
	var pos :Vector3 = global_position
	var basis :Basis = global_transform.basis
	
	for idx in total_member:
		var offset :Vector3 = _formation_offsets[idx] * formation_density
		_formation_positions[idx] = (pos + basis.xform(offset))
		
		var member :CavalryMember = member_scene.instance()
		member.squad = self
		member.name = "%s_member_%s" % [name, idx]
		
		member.headgear = member_headgear
		member.armor = member_armor
		member.shield = member_shield
		member.melee_weapon = member_melee_weapon
		member.range_weapon = member_range_weapon
		member.material = member_material
		
		member.horse_skin = horse_skins[_rng.randi_range(0, horse_skins.size() - 1)]
		
		member.hp = member_hp
		member.max_hp = member_max_hp
		
		member.connect("on_set_damage_to_tile", self, "_on_member_set_damage_to_tile")
		member.connect("on_set_damage_to_target", self, "_on_member_set_damage_to_target")
		member.connect("on_member_dead", self, "_on_local_member_die", [idx])
		
		add_child(member)
		member.set_as_toplevel(true)
		member.translation = _formation_positions[idx]
		_members.append(member)
		
	_alive_members.append_array(_members)
	emit_signal("on_squad_member_ready", self, _members)
	
func _on_member_dead(member :SquadMember):
	._on_member_dead(member)
	
	if visible and not _horse_audio.playing:
		_horse_audio.stream = horse_dead.pick_random()
		_horse_audio.play()
	
func _init_formations():
	._init_formations()
	
	# flag carrier were back
	_formation_offsets = [
		Vector3.FORWARD, 
		Vector3.LEFT, Vector3.RIGHT, 
		Vector3.BACK
	]
	_formation_positions = _formation_offsets.duplicate()
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	_follow_path_proccess(delta, global_position)
	
func _move_to(tile_id :Vector2, use_safe :bool):
	._move_to(tile_id, use_safe)
	
	if not _is_master:
		return
		
	_charges = 0
	emit_signal("on_cav_charge_buildup", self, _charges)
	
func _on_walking(delta :float):
	if visible and _is_moving and _walk_timer.is_stopped():
		_walk_timer.wait_time = 0.2
		_walk_timer.start()
		_step_audio.stream = walk_sounds.pick_random()
		_step_audio.play()
		
remote func _stop():
	._stop()
	
	_charges = 0
	emit_signal("on_cav_charge_buildup", self, _charges)
	
func _on_current_tile_updated(from_id :Vector2, to_id :Vector2):
	._on_current_tile_updated(from_id, to_id)
	
	if not _is_master:
		return
		
	# if there are chases enemy
	if not is_instance_valid(chase_enemy):
		return
		
	if _is_charge_blocked(to_id):
		if not _horse_audio.playing:
			_horse_audio.stream = horse_dead.pick_random()
			_horse_audio.play()
		
		chase_enemy = null
		stop(false)
		return
		
	_charges += 1
	emit_signal("on_cav_charge_buildup", self, _charges)
	
func _on_finish_travel(from_id :Vector2, to_id :Vector2):
	._on_finish_travel(from_id, to_id)
	
	if not _is_master:
		return
		
	# on stop, there will be impact
	# the more  of_charges value 
	# the more damage it dealt
	if _charges >= min_charge_required:
		_cav_charge(to_id, charge_damage + _charges)
		
	_charges = 0
	
# this function will check if next path 
# is blocked by enemy unit, if it, stop cav
# so charge mechanic still be use
func _is_charge_blocked(tile_id :Vector2) -> bool:
	var e :Array = _get_enemy_in_position(unit_position[tile_id])
	return e[1] and _paths.size() > 2
	
func _cav_charge(tile_id :Vector2, attack_damage :int):
	var unit_positions :Array = unit_position[tile_id]
	if unit_positions.empty():
		return
		
	var squad_hit :int = 0
	for enemy_squad in unit_positions:
		if not is_instance_valid(enemy_squad):
			continue
			
		# we dont want clamp ourself or our kin
		if enemy_squad == self or enemy_squad.team == team:
			continue
			
		var members :Array = enemy_squad.get_members(true)
		if members.empty():
			continue
			
		squad_hit += 1
			
		for idx in members.size():
			if not members[idx].is_dead:
				enemy_squad.take_damage(int(attack_damage * clamp(randf(), 0.5, 1)), idx, get_path())
	
	if squad_hit > 0:
		if not _horse_audio.playing:
			_horse_audio.stream = horse_dead.pick_random()
			_horse_audio.play()
		
		emit_signal("on_cav_charge", self)

func _ajust_formation(pos :Vector3, delta :float):
	var members = get_members()
	
	var basis :Basis = global_transform.basis
	for i in _formation_offsets.size():
		var offset :Vector3 = _formation_offsets[i] * formation_density
		_formation_positions[i] = (pos + basis.xform(offset))
		
	for idx in members.size():
		var m = members[idx]
		if visible:
			m.translation = m.translation.linear_interpolate(_formation_positions[idx], 5 * delta)
			
		else:
			m.translation = _formation_positions[idx]
		
func _on_enemy_in_range(delta :float, pos :Vector3, enemy_pos :Vector3):
	._on_enemy_in_range(delta, pos, enemy_pos)
	
	if not can_attack:
		return
		
	if not _is_moving:
		# align Y
		var look :Vector3 = enemy_pos
		look.y = pos.y
		
		var dir_to :Vector3 = pos.direction_to(look)
		
		# look at enemy position
		if _can_look_at(pos, look, dir_to):
			var t:Transform = transform.looking_at(look, Vector3.UP)
			transform = transform.interpolate_with(t, turning_speed * delta)
		
	if _is_in_melee_range(enemy):
		_perform_melee_attack()
		return
		
	_perform_range_attack()

func _perform_melee_attack():
	if _melee_attack_timer.is_stopped():
		_melee_attack_timer.wait_time = melee_attack_speed
		_melee_attack_timer.start()
		
		_melee_engagement = true
		_range_engagement = false
		
		var iddles :Array = get_iddle_members()
		if iddles.empty():
			return
			
		for i in _members:
			i.prepare_melee_weapon()
			
		# tell to attack 
		# use melee weapon
		var m :SquadMember = iddles.pick_random()
		var enemy_member :SquadMember = enemy.pick_closes(m.global_position, false)
		var target_idx :int = enemy.get_member_index(enemy_member)
		if target_idx == -1:
			return
		
		m.target_idx = target_idx
		m.enemy = enemy_member
		m.melee_attack()
		
func _perform_range_attack():
	if not _has_range_weapon:
		return
		
	if _range_attack_timer.is_stopped():
		_range_attack_timer.wait_time = range_attack_speed
		_range_attack_timer.start()
		
		_range_engagement = true
		_melee_engagement = false
		
		var iddles :Array = get_iddle_members()
		if iddles.empty():
			return
			
		for i in _members:
			i.prepare_range_weapon()
			
		for i in iddles:
			var enemy_member :SquadMember = enemy.pick_member(false)
			var target_idx :int = enemy.get_member_index(enemy_member)
			if target_idx == -1:
				continue
				
			var m :SquadMember = i
			m.target_idx = target_idx
			m.enemy = enemy_member
			m.range_attack()
				

func _move_to_next_path(delta :float, pos :Vector3, to :Vector3):
	#._move_to_next_path(delta, pos, to)
	
	# align Y
	var look :Vector3 = to
	look.y = pos.y
	
	var t:Transform = transform.looking_at(look, Vector3.UP)
	transform = transform.interpolate_with(t, turning_speed * delta)
	
	var _speed = (speed * 0.5) if attack_move else speed
	translation += pos.direction_to(to) * _speed * delta
	
