extends BaseTileUnit
class_name BaseSquad

signal on_squad_member_ready(squad, members)
signal on_squad_member_resurect(squad, member)
signal on_squad_member_dead(squad, member)
signal on_squad_taking_damage(squad, amount)
signal on_squad_taking_heal(squad)

const walk_sounds = [
	preload("res://assets/sounds/walks/walk_1.wav"),
	preload("res://assets/sounds/walks/walk_2.wav"),
	preload("res://assets/sounds/walks/walk_3.wav")
]
const hurt_sounds = [
	preload("res://assets/sounds/hurt/hurt_1.wav"),
	preload("res://assets/sounds/hurt/hurt_2.wav"),
	preload("res://assets/sounds/hurt/hurt_3.wav"),
	preload("res://assets/sounds/hurt/hurt_4.wav"),
	preload("res://assets/sounds/hurt/hurt_5.wav"),
	preload("res://assets/sounds/hurt/hurt_6.wav"),
	preload("res://assets/sounds/hurt/hurt_7.wav"),
	preload("res://assets/sounds/hurt/hurt_8.wav"),
	preload("res://assets/sounds/hurt/hurt_9.wav"),
	preload("res://assets/sounds/hurt/hurt_10.wav"),
	preload("res://assets/sounds/hurt/hurt_11.wav"),
	preload("res://assets/sounds/hurt/hurt_12.wav"),
	preload("res://assets/sounds/hurt/hurt_13.wav"),
	preload("res://assets/sounds/hurt/hurt_14.wav"),
	preload("res://assets/sounds/hurt/hurt_15.wav"),
	preload("res://assets/sounds/hurt/hurt_16.wav")
]
const death_sounds = [
	preload("res://assets/sounds/death/dead_1.wav"),
	preload("res://assets/sounds/death/dead_2.wav"),
	preload("res://assets/sounds/death/dead_3.wav"),
	preload("res://assets/sounds/death/dead_4.wav"),
	preload("res://assets/sounds/death/dead_5.wav"),
	preload("res://assets/sounds/death/wilhem_scream.wav")
]

export var member_scene :PackedScene
export var can_attack :bool
export var turning_speed :float = 8
export var melee_attack_speed :float = 0.8
export var range_attack_speed :float = 0.8
export var formation_density :float = 0.35

export var member_headgear :PackedScene
export var member_armor :PackedScene
export var member_shield :PackedScene
export var member_melee_weapon :PackedScene
export var member_range_weapon :PackedScene
export var member_material :SpatialMaterial

export var member_hp :int = 100
export var member_max_hp :int = 100
export var heal_amount :int = 10
export var reinfoce_tiles :Array = []
export var squad_role :int

var member_alive :int

export var show_move_indicator:bool = false
export var enable_blood :bool

# MUST SET
var camera :Camera
var floating_info :FloatingSquadInfo
var unit_indexing :Dictionary

puppet var _puppet_rotation_y :float
puppet var _puppet_enemy :NodePath
puppet var _puppet_is_moving :bool

var _formation_offsets :Array = [] # [Vector3]
var _formation_positions :Array = [] # [Vector3]
var _members :Array = [] # [SquadMember]
var _melee_ranges :Array = []
var _current_tile_v3 :Vector3

var _melee_attack_timer :Timer
var _range_attack_timer :Timer
var _walk_timer :Timer
var _heal_timer :Timer
var _path_indicator :Spatial
#var _path_indicator2 :Spatial

var _heal_interupt :bool = false

var _step_audio :AudioStreamPlayer3D
var _combat_audio :AudioStreamPlayer3D
var _unit_audio :AudioStreamPlayer3D
var _blood_particle :CPUParticles

var attacked_by :NodePath

onready var _has_shield :bool = member_shield != null
onready var _has_range_weapon :bool = member_range_weapon != null
var _member_spawned :bool = false
var _range_engagement :bool

func _ready():
	Global.connect("on_setting_updated", self, "_on_setting_updated")
	
	_blood_particle = preload("res://assets/blood_particle/blood_particle.tscn").instance()
	_blood_particle.set_as_toplevel(true)
	add_child(_blood_particle)
	
	_melee_attack_timer = Timer.new()
	_melee_attack_timer.one_shot = true
	_melee_attack_timer.autostart = false
	_melee_attack_timer.wait_time = melee_attack_speed
	add_child(_melee_attack_timer)
	
	_range_attack_timer = Timer.new()
	_range_attack_timer.one_shot = true
	_range_attack_timer.autostart = false
	_range_attack_timer.wait_time = range_attack_speed
	add_child(_range_attack_timer)
	
	_walk_timer = Timer.new()
	_walk_timer.one_shot = true
	_walk_timer.autostart = false
	_walk_timer.wait_time = 0.43
	add_child(_walk_timer)
	
	_heal_timer = Timer.new()
	_heal_timer.one_shot = true
	_heal_timer.autostart = false
	_heal_timer.wait_time = 5
	_heal_timer.connect("timeout", self, "_on_heal_timer")
	add_child(_heal_timer)
	
	_heal_timer.start()
	
	_step_audio = AudioStreamPlayer3D.new()
	_step_audio.bus = Global.bus_sfx
	add_child(_step_audio)
	
	_combat_audio = AudioStreamPlayer3D.new()
	_combat_audio.bus = Global.bus_sfx
	add_child(_combat_audio)
	
	_unit_audio = AudioStreamPlayer3D.new()
	_unit_audio.bus = Global.bus_sfx
	add_child(_unit_audio)
	
	_path_indicator = preload("res://assets/squad_path_indicator/squad_path_indicator.tscn").instance()
	_path_indicator.material = member_material
	add_child(_path_indicator)
	_path_indicator.set_as_toplevel(true)
	_path_indicator.visible = false
		
#	_path_indicator2 = preload("res://assets/squad_path_indicator/squad_path_indicator.tscn").instance()
#	add_child(_path_indicator2)
#	_path_indicator2.set_as_toplevel(true)
	
	_init_formations()
	
	# add little bit of delay
	yield(get_tree().create_timer(0.5),"timeout")
	_spawn_members()
	_member_spawned = true

	if show_move_indicator:
		_path_indicator.visible = true
		_path_indicator.translation = global_position
		
func _on_setting_updated(d :SettingData):
	show_move_indicator = d.show_unit_tile
	_path_indicator.visible = d.show_unit_tile
	enable_blood = d.enable_blood
	
func _init_formations():
	pass
	
func _spawn_members():
	var pos :Vector3 = global_position
	var basis :Basis = global_transform.basis
	
	for idx in member_alive:
		var offset :Vector3 = _formation_offsets[idx] * formation_density
		_formation_positions[idx] = (pos + basis.xform(offset))
		
		var member :SquadMember = member_scene.instance()
		member.squad = self
		member.name = "%s_member_%s" % [name, idx]
		
		member.headgear = member_headgear
		member.armor = member_armor
		member.shield = member_shield
		member.melee_weapon = member_melee_weapon
		member.range_weapon = member_range_weapon
		member.material = member_material
		
		member.hp = member_hp
		member.max_hp = member_max_hp
		
		member.connect("on_set_damage_to_tile", self, "_on_member_set_damage_to_tile")
		member.connect("on_set_damage_to_target", self, "_on_member_set_damage_to_target")
		member.connect("on_member_dead", self, "_on_member_dead")
		
		add_child(member)
		member.set_as_toplevel(true)
		member.translation = _formation_positions[idx]
		_members.append(member)
		
	emit_signal("on_squad_member_ready", self, _members)

func _on_member_set_damage_to_tile(_member :SquadMember, tile_id :Vector2, attack_damage :int):
	if not _is_master:
		return
		
	# 25 % chance of doing no damage
	if randf() < 0.25:
		return
		
	if not unit_position.has(tile_id):
		return
		
	var unit_positions :Array = unit_position[tile_id]
	if unit_positions.empty():
		return
		
	var enemy_squad = unit_positions.pick_random()
	if not is_instance_valid(enemy_squad):
		return
		
	# 50 % chance of doing no damage if moving
	if enemy_squad.is_moving() and randf() < 0.50:
		return
		
	var members :Array = enemy_squad.get_members()
	if members.empty():
		return
		
	# set damage to random member
	var idx :int = enemy_squad.get_member_index(members.pick_random())
	enemy_squad.take_damage(attack_damage, idx, get_path())
	
func _on_member_set_damage_to_target(_member :SquadMember, target :SquadMember, target_member_idx :int, attack_damage :int):
	if not _is_master:
		return
		
	# 15 % chance of doing no damage
	if randf() < 0.15:
		return
		
	# bonus damage if attack from flank
	var dmg :int = attack_damage
	if _is_on_flank_of(target.squad):
		dmg = attack_damage * 2
		
	target.squad.take_damage(dmg, target_member_idx, get_path())
	
func _on_member_dead(member :SquadMember):
	if _members.has(member):
		member_alive -= 1
		
		if not _blood_particle.emitting and visible and enable_blood:
			_blood_particle.translation = member.global_position
			_blood_particle.emitting = true
			
		if not _unit_audio.playing:
			_unit_audio.stream = death_sounds[randi() % 4]
		
			if randf() < 0.08:
				_unit_audio.stream = death_sounds[5] # wilhem
		
			_unit_audio.play()
		
		
		emit_signal("on_squad_member_dead", self, member)
		
	if member_alive <= 0:
		set_dead(false)
		
func _on_current_tile_updated(from_id :Vector2, to_id :Vector2):
	._on_current_tile_updated(from_id, to_id)
	
	_current_tile_v3 = nav.get_pos_v3(current_tile)
	
	if not show_move_indicator:
		return
		
	_path_indicator.visible = (nav != null)
	#_path_indicator2.visible = (nav != null)
	
	if _path_indicator.visible:
		_path_indicator.translation = nav.get_pos_v3(to_id)
		
#	if _path_indicator2.visible:
#		_path_indicator2.translation = nav.get_pos_v3(from_id)
	
func sync_update() -> void:
	.sync_update()
	
	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_is_moving", _is_moving)
		rset_unreliable("_puppet_rotation_y", global_rotation.y)
		
		if _has_enemy:
			rset_unreliable("_puppet_enemy", enemy.get_path())
			
		else:
			rset_unreliable("_puppet_enemy", NodePath(""))
			
func has_range_weapon() -> bool:
	return _has_range_weapon
	
func moving(delta :float) -> void:
	.moving(delta)
	
	if is_dead:
		return
		
	var pos :Vector3 = global_position
	_ajust_formation(pos, delta)
	_set_floating_info_pos(pos, delta)
	_attack_enemy_proccess(pos, delta)
	
func _ajust_formation(pos :Vector3, delta :float):
	var basis :Basis = global_transform.basis
	
	for i in _formation_offsets.size():
		var offset :Vector3 = _formation_offsets[i] * formation_density
		_formation_positions[i] = (pos + basis.xform(offset))
		
	var members = get_members()
	for idx in members.size():
		var m = members[idx]
		if m.iddle or m.range_mode:
			m.translation = m.translation.linear_interpolate(_formation_positions[idx], 5 * delta)
		
	if _is_moving and _walk_timer.is_stopped():
		_walk_timer.start()
		_step_audio.stream = walk_sounds.pick_random()
		_step_audio.play()
	
func _attack_enemy_proccess(pos :Vector3, delta :float):
	# because this script run on both master & puppet
	# must check via is_instance_valid enemy
	if is_instance_valid(enemy):
		if _is_in_range(enemy):
			_on_enemy_in_range(delta, pos, enemy.global_position)
			return
			
	_has_enemy = false
	enemy = null
	
func get_avg_member_pos(pos :Vector3) -> Vector3:
	var m :Array = get_members()
	if m.empty():
		return pos
	var npos = pos
	for i in m:
		npos += i.global_position
		
	return npos / (m.size() + 1)
	
func _set_floating_info_pos(pos :Vector3, delta :float):
	# track floating ui
	if not _member_spawned:
		return
		
	if not floating_info:
		return
		
	floating_info.visible = _current_visible
	if not floating_info.visible:
		return
		
	# validate and must not behind cam
	var _h = Vector3(0, 0.75, 0)
	if camera.is_position_behind(pos + _h):
		return
		
	 #  default pos by tilemap nav pos
	var _pos :Vector3 = _current_tile_v3
	var _offset_v2 = Vector2.ZERO
	var _crowded :bool = false
	
	if unit_position.has(current_tile):
		var tiles = unit_position[current_tile]
		var size = tiles.size()
		
		# 30 were limited so .find() is fine
		if size > 1 and size < 30: 
			var idx = unit_indexing[self]
			var offset_x = ((idx % 3) - 1) * 85
			var offset_y = (idx / 3) * 55
			_offset_v2 = Vector2(offset_x, offset_y)
			var rows = int(ceil(size / 3.0))
			var grid_height = rows * 25
			_offset_v2.y -= grid_height
			_crowded = true
			
	if not _crowded:
		_pos = get_avg_member_pos(pos)
		
	var _screen_pos = camera.unproject_position(_pos + _h)
	floating_info.rect_global_position = (_screen_pos - floating_info.rect_pivot_offset) + _offset_v2
	
func get_member_index(m :SquadMember) -> int:
	return _members.find(m)
		
func pick_member(iddle_one :bool = true) -> SquadMember:
	if not iddle_one:
		var alives = get_members()
		return null if alives.empty() else alives.pick_random()
		
	var iddles = get_iddle_members()
	return null if iddles.empty() else iddles.pick_random()
	
func pick_closes(pos :Vector3, iddle_one :bool = true) -> SquadMember:
	var iddles = get_iddle_members() if iddle_one else get_members()
	if iddles.empty():
		return null
		
	var current = iddles[0]
	var dist = current.global_position.distance_squared_to(pos)
	for i in iddles:
		if i == current:
			continue
			
		var dist2 = i.global_position.distance_squared_to(pos)
		if dist2 < dist:
			dist = dist2
			current = i
			
	return current
	
func get_iddle_members() -> Array:
	var iddles = []
	for i in get_members():
		if i.iddle:
			iddles.append(i)
			
	return iddles
	
func get_members(all :bool = false) -> Array:
	var alives = []
	for i in _members:
		if not i.is_dead or all:
			alives.append(i)
			
	return alives
	
func _on_heal_timer():
	if not _is_master or is_dead:
		return
		
	_heal_timer.wait_time = rand_range(4, 8)
	_heal_timer.start()
	
	if _heal_interupt:
		_heal_interupt = false
		return
		
	if _has_enemy or _is_moving:
		return
		
	_resurecting()
	_healing()

func _healing():
	# heal first
	for idx in _members.size():
		var m = _members[idx]
		if m.is_dead:
			continue
			
		if m.hp >= member_max_hp:
			continue
			
		_members[idx].hp = int(clamp(_members[idx].hp + heal_amount, 0, member_max_hp))
		rpc_unreliable("_taking_heal", _members[idx].hp, idx) # 0: healing
		return
		
func _resurecting():
	if not (current_tile in reinfoce_tiles):
		return
		
	# resurect the dead
	for idx in _members.size():
		var m = _members[idx]
		if m.is_dead:
			rpc("_resurect", idx)
			return

func _is_in_melee_range(target):
	return target.current_tile in _melee_ranges
	
func _is_on_flank_of(target) -> bool:
	var dir = target.current_tile.direction_to(current_tile)
	var forward = Vector2(-target.transform.basis.z.x,-target.transform.basis.z.z).normalized()
	var dot = forward.dot(dir)
	return !(dot > 0.5)
	
func take_damage(amount :int, member_idx :int, from :NodePath):
	if is_dead:
		return
		
	# shield provide 20% chance of receive no damage
	# even if this hybrid unit using a range weapon
	if _has_shield and randf() < 0.20:
		return
		
	if member_idx > _members.size() - 1 or member_idx == -1:
		return
		
	attacked_by = from
	
	var m :SquadMember = _members[member_idx]
	if amount > 0:
		m.take_damage(amount)
	
	rpc_unreliable("_taking_damage", amount, m.hp, member_idx, from)
	
remotesync func _resurect(member_idx :int):
	if member_idx > _members.size() - 1 or member_idx == -1:
		return
		
	var m :SquadMember = _members[member_idx]
	m.resurect()
	member_alive += 1
	
	emit_signal("on_squad_member_resurect", self, m)
	
remotesync func _taking_heal(hp_remain :int, member_idx :int):
	if member_idx > _members.size() - 1 or member_idx == -1:
		return
		
	var m :SquadMember = _members[member_idx]
	m.hp = hp_remain
	emit_signal("on_squad_taking_heal", self)
		
remotesync func _taking_damage(amount :int, hp_remain :int, member_idx :int, from :NodePath):
	if member_idx > _members.size() - 1 or member_idx == -1:
		return
		
	attacked_by = from
	
	if _is_master and not _heal_interupt:
		_heal_interupt = true
		
		# if on range engagement
		# and getting clap by melee enemy
		# change attention to them
		if _range_engagement:
			var s = get_node_or_null(attacked_by)
			if is_instance_valid(s):
				if _is_in_melee_range(s):
					enemy = s
					_has_enemy = true
					_on_enemy_set()
					_range_engagement = false
					
	var m :SquadMember = _members[member_idx]
	m.hp = hp_remain
	
	if not _unit_audio.playing and amount > 0:
		_unit_audio.stream = hurt_sounds.pick_random()
		_unit_audio.play()
		
	emit_signal("on_squad_taking_damage", self, amount)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not is_dead:
		rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, 25 * delta)
		enemy = get_node_or_null(_puppet_enemy)
		_is_moving = _puppet_is_moving
		
func update_spotting():
	.update_spotting()
	
	_melee_ranges = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.ARROW_DIRECTIONS, current_tile, 1
	) + [current_tile]


