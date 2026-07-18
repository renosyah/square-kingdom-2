extends BaseTileUnit
class_name BaseSquad

signal on_squad_member_ready(squad, members)
signal on_squad_member_resurect(squad, member)
signal on_squad_member_dead(squad, member)
signal on_squad_taking_damage(squad, amount)
signal on_squad_taking_heal(squad)
signal on_squad_dead(unit)
signal on_squad_set_modifier(squad, datas)
signal on_squad_modifier_clear(squad)

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
	preload("res://assets/sounds/hurt/hurt_16.wav"),
	preload("res://assets/sounds/memes/jokowi_kaget.wav"),
	preload("res://assets/sounds/memes/my_leg.wav")
]
const death_sounds = [
	preload("res://assets/sounds/death/dead_1.wav"),
	preload("res://assets/sounds/death/dead_2.wav"),
	preload("res://assets/sounds/death/dead_3.wav"),
	preload("res://assets/sounds/death/dead_4.wav"),
	preload("res://assets/sounds/death/dead_5.wav"),
	preload("res://assets/sounds/memes/wilhem_scream.wav")
]

const MIN_MELEE_SPEED = 0.11
const MIN_RANGE_SPEED = 0.12
const MIN_MOVE_SPEED = 0.14
const MAX_MELEE_SPEED = 3.0
const MAX_RANGE_SPEED = 5.0
const MAX_MOVE_SPEED = 3.0

export var member_scene :PackedScene
export var can_attack :bool
export var turning_speed :float = 8
export var melee_attack_speed :float = 0.8
export var range_attack_speed :float = 0.8
export var formation_density :float = 0.35

var melee_attack_speed_mul :float = 0.0
var range_attack_speed_mul :float = 0.0
var damage_receive_mul :float = 0.0
var speed_mul :float = 0.0
var melee_damage_mul :float = 0.0
var range_damage_mul :float = 0.0

export var member_headgear :PackedScene
export var member_armor :PackedScene
export var member_shield :PackedScene
export var member_melee_weapon :PackedScene
export var member_range_weapon :PackedScene
export var member_material :SpatialMaterial

export var total_member :int
export var member_hp :int = 100
export var member_max_hp :int = 100
export var heal_amount :int = 10
export var reinfoce_tiles :Array = []
export var squad_role :int
export var squad_icon :StreamTexture
export var squad_attribute :Array
export var squad_ability_idx :int = 0
export var banner_icon_idx :int
export var banner_icon :StreamTexture
export var rapid_fire_mode :bool = false
export var is_hero :bool

var member_alive :int

export var enable_blood :bool # influence by setting
export var enable_squad_tile_indicator :bool = false # influence by setting
export var show_move_to_indicator :bool = false # gameplay

export var attack_range :int = 1
var unit_position :Dictionary = {} # {Vector2 : [BaseTileUnit]}
var chase_enemy = null # cycle warning set to null
var enemy = null # cycle warning set to null
var attack_move :bool

var is_dead :bool = false
var _has_enemy :bool # for easier

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
var _alive_members :Array = [] # [SquadMember]
var _attack_tile_ranges :Array = []
var _melee_tile_ranges :Array = []
var _current_tile_v3 :Vector3

var _melee_attack_timer :Timer
var _range_attack_timer :Timer
var _walk_timer :Timer
var _heal_timer :Timer
var _tile_indicator :Spatial
var _move_to_indicator :Spatial

var _send_rpc_pending_timer :Timer
var _send_unreliable_rpc_pending_timer :Timer

var _taking_damages_pending :Array = [] # [[]]
var _member_deads_pending :Array = [] # [[]]
var _pending_modifier_send :Array = [] # [[]]
var _heal_interupt :bool = false

var _step_audio :AudioStreamPlayer3D
var _combat_audio :AudioStreamPlayer3D
var _unit_audio :AudioStreamPlayer3D
var _blood_particle :CPUParticles

var _visible_state :bool
var attacked_by :NodePath

onready var _has_shield :bool = member_shield != null
onready var _has_range_weapon :bool = member_range_weapon != null
var _member_spawned :bool = false
var _melee_engagement :bool
var _range_engagement :bool

var _ability_cooldown :Timer

var attach_melee_targets :Array # any
var attach_range_targets :Array # any

func _ready():
	if _is_network_master():
		Global.connect("on_global_tick", self, "_on_global_tick")
		
	Global.connect("on_setting_updated", self, "_on_setting_updated")
	connect("tree_exiting", self, "_on_tree_exiting")
	
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
	add_child(_walk_timer)
	
	_heal_timer = Timer.new()
	_heal_timer.one_shot = true
	_heal_timer.autostart = false
	_heal_timer.wait_time = 5
	_heal_timer.connect("timeout", self, "_on_heal_timer")
	add_child(_heal_timer)
	_heal_timer.start()
	
	_send_rpc_pending_timer = Timer.new()
	_send_rpc_pending_timer.one_shot = true
	_send_rpc_pending_timer.autostart = false
	_send_rpc_pending_timer.wait_time = 0.2
	add_child(_send_rpc_pending_timer)
	
	_send_unreliable_rpc_pending_timer = Timer.new()
	_send_unreliable_rpc_pending_timer.one_shot = true
	_send_unreliable_rpc_pending_timer.autostart = false
	_send_unreliable_rpc_pending_timer.wait_time = 0.08
	add_child(_send_unreliable_rpc_pending_timer)
	
	_ability_cooldown = Timer.new()
	_ability_cooldown.one_shot = true
	_ability_cooldown.autostart = false
	_ability_cooldown.wait_time = 1
	add_child(_ability_cooldown)
	
	_step_audio = AudioStreamPlayer3D.new()
	_step_audio.bus = Global.bus_sfx
	_step_audio.unit_db = 3
	add_child(_step_audio)
	
	_combat_audio = AudioStreamPlayer3D.new()
	_combat_audio.bus = Global.bus_sfx
	add_child(_combat_audio)
	
	_unit_audio = AudioStreamPlayer3D.new()
	_unit_audio.bus = Global.bus_sfx
	add_child(_unit_audio)
	
	_tile_indicator = preload("res://assets/squad_path_indicator/squad_path_indicator.tscn").instance()
	_tile_indicator.material = member_material
	add_child(_tile_indicator)
	_tile_indicator.set_as_toplevel(true)
	_tile_indicator.visible = false
		
	if Global.current_root:
		_move_to_indicator = preload("res://assets/squad_path_indicator/squad_path_indicator_destination.tscn").instance()
		_move_to_indicator.material = member_material
		_move_to_indicator.squad_icon = squad_icon
		Global.current_root.add_child(_move_to_indicator)
		_move_to_indicator.set_as_toplevel(true)
		_move_to_indicator.visible = false
	
	_init_formations()
	
	# add little bit of delay
	yield(get_tree().create_timer(0.5),"timeout")
	_spawn_members()
	
	_member_spawned = true
	_current_tile_v3 = nav.get_pos_v3(current_tile)
	_tile_indicator.visible = enable_squad_tile_indicator
	_tile_indicator.translation = _current_tile_v3
	
func _on_tree_exiting():
	if _move_to_indicator:
		_move_to_indicator.queue_free()
	
func _on_setting_updated(d :SettingData):
	enable_squad_tile_indicator = d.show_unit_tile
	enable_blood = d.extra_effect
	
	_tile_indicator.visible = enable_squad_tile_indicator
	_tile_indicator.translation = _current_tile_v3
	
	if _is_moving:
		_move_to_indicator.visible = enable_squad_tile_indicator and show_move_to_indicator
	
func in_melee_engagement() -> bool:
	return _melee_engagement and _has_enemy
	
func in_range_engagement() -> bool:
	return _range_engagement and _has_enemy
	
# set chase_enemy = UNIT
# chase_target()
# move_to will set chase_enemy to NULL
func chase_target():
	if is_instance_valid(chase_enemy):
		# give up the chase if
		# diffrent nav layer
		# no path to it
		if chase_enemy.nav_layer != nav_layer or chase_enemy == self:
			chase_enemy = null
			return
			
		if _is_still_in_ranges(chase_enemy):
			enemy = chase_enemy
			_has_enemy = true
			_on_enemy_set()
			return
			
		_move_to(chase_enemy.current_tile, false)
		if _paths.empty():
			chase_enemy = null
			
func move_to(tile_id :Vector2):
	chase_enemy = null
	_move_to(tile_id, true)
	
func _move_to(tile_id :Vector2, use_safe :bool):
	if is_dead:
		return
		
	if not _is_master or not is_instance_valid(nav):
		return
		
	_melee_engagement = false
	_range_engagement = false
	_has_enemy = false
	enemy = null
	
	var v :Array = _get_tile_path(tile_id, use_safe)
	if v.empty():
		return
		
	_last_to = global_position
	_move_to_indicator.global_position = nav.get_pos_v3(tile_id)
	_move_to_indicator.visible = enable_squad_tile_indicator and show_move_to_indicator
	
	_is_moving = true
	_paths.clear()
	_paths.append_array(v)
	
	if attack_move:
		update_spotting()
		_scan_area()
	
func _init_formations():
	pass
	
func _spawn_members():
	var pos :Vector3 = global_position
	var basis :Basis = global_transform.basis
	
	member_alive = total_member
	
	for idx in total_member:
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
		
		if banner_icon_idx != 0:
			member.is_bannerman = total_member > 1 and idx == 0
			member.banner_icon = banner_icon
		
		member.connect("on_set_damage_to_tile", self, "_on_member_set_damage_to_tile")
		member.connect("on_set_damage_to_target", self, "_on_member_set_damage_to_target")
		member.connect("on_member_dead", self, "_on_local_member_die", [idx])
		
		add_child(member)
		member.set_as_toplevel(true)
		member.translation = _formation_positions[idx]
		_members.append(member)
		
	_alive_members.append_array(_members)
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
		
	var members :Array = enemy_squad.get_members()
	if members.empty():
		return
		
	# set damage to random member
	var idx :int = enemy_squad.get_member_index(members.pick_random())
	enemy_squad.take_damage(_get_attack_damage(1, attack_damage), idx, get_path())
	
	while not attach_range_targets.empty():
		enemy_squad.add_child(attach_range_targets.front())
		attach_range_targets.pop_front()
		
	
func _on_member_set_damage_to_target(_member :SquadMember, target :SquadMember, target_member_idx :int, attack_damage :int):
	if not _is_master:
		return
		
	# 15 % chance of doing no damage
	if randf() < 0.15:
		return
		
	# bonus damage if attack from flank
	var dmg :int = attack_damage
	var sq = target.squad
	if _is_on_flank_of(sq):
		dmg = attack_damage * 2
		
	sq.take_damage(_get_attack_damage(0, dmg), target_member_idx, get_path())
	
	while not attach_melee_targets.empty():
		sq.add_child(attach_melee_targets.front())
		attach_melee_targets.pop_front()
		
	if _member.melee_has_splash():
		_apply_melee_splash_damage(sq.current_tile, dmg * 0.5)
		
func _apply_melee_splash_damage(tile_id :Vector2, damage :int):
	if not unit_position.has(tile_id):
		return
		
	var unit_positions :Array = unit_position[tile_id]
	if unit_positions.empty():
		return
		
	var count :int = int(randi() % unit_positions.size())
	for _i in count:
		var enemy_squad = unit_positions.pick_random()
		if not is_instance_valid(enemy_squad):
			continue
			
		var members :Array = enemy_squad.get_members()
		if members.empty():
			continue
			
		var count_member :int = int(randi() % members.size())
		for _o in count_member:
			var idx :int = enemy_squad.get_member_index(members.pick_random())
			enemy_squad.take_damage(_get_attack_damage(0, damage), idx, get_path())
	
func _on_local_member_die(member :SquadMember, idx :int):
	_member_deads_pending.append([idx, member.attacked_by])
	
func _on_current_tile_updated(from_id :Vector2, to_id :Vector2):
	._on_current_tile_updated(from_id, to_id)
	
	_current_tile_v3 = nav.get_pos_v3(current_tile)
	_tile_indicator.translation = _current_tile_v3
	
	if not _is_master:
		return
		
	if is_instance_valid(chase_enemy):
		# stop the chase
		# if chase_enemy is dead
		if chase_enemy.is_dead:
			chase_enemy = null
			stop(false)
			return
			
		if _is_still_in_ranges(chase_enemy):
			enemy = chase_enemy
			_has_enemy = true
			_on_enemy_set()
			return
		
	if attack_move:
		_scan_area()
		
func _on_finish_travel(from_id :Vector2, to_id :Vector2):
	._on_finish_travel(from_id, to_id)
	
	_move_to_indicator.visible = false
	
	if _is_master:
		_scan_area()
		
func sync_update() -> void:
	#.sync_update()

	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_position)
		rset_unreliable("_puppet_current_tile", current_tile)
		
		rset_unreliable("_puppet_is_moving", _is_moving)
		rset_unreliable("_puppet_rotation_y", global_rotation.y)
		
		if is_instance_valid(enemy):
			rset_unreliable("_puppet_enemy", enemy.get_path())
			
		else:
			rset_unreliable("_puppet_enemy", NodePath(""))
			
func last_sync_update() -> void:
	#.last_sync_update()
	
	if not is_dead and _is_master and _is_online:
		rset("_puppet_translation", global_position)
		rset("_puppet_current_tile", current_tile)
		
func has_range_weapon() -> bool:
	return _has_range_weapon
	
func retreat(use_rpc :bool = true):
	if _is_master or not use_rpc:
		_retreat()
		return
		
	# prevent rpc spam
	if not _debounce_rpc_timer.is_stopped():
		return
		
	_debounce_rpc_timer.start()
	
	# call stop, tell master to stop from other peer
	rpc_id(get_network_master(), "_retreat")
	
remote func _retreat():
	_is_moving = false
	_paths.clear()
	
	attack_move = false
	_has_enemy = false
	enemy = null
	chase_enemy = null
	
	if reinfoce_tiles.empty():
		_move_to(current_tile - dir_front() * 2, true) # move back
		return
		
	_move_to(reinfoce_tiles.pick_random(), true)
	
func on_stop():
	.on_stop()
	
	_move_to_indicator.visible = false
	_has_enemy = false
	enemy = null
	chase_enemy = null
	
func moving(delta :float) -> void:
	.moving(delta)
	
	_send_rpc_pending()
	
	if is_dead:
		return
		
	_on_walking(delta)
	
	var pos :Vector3 = global_position
	_ajust_formation(pos, delta)
	_set_floating_info_pos(pos, delta)
	_attack_enemy_proccess(pos, delta)
	
# prevent bursh of damage info send over network
# check all the pending and send all at once
func _send_rpc_pending():
	# unrelaible
	if _send_unreliable_rpc_pending_timer.is_stopped():
		_send_rpc_unreliable_pending()
		_send_unreliable_rpc_pending_timer.start()
	
	# relaible
	if _send_rpc_pending_timer.is_stopped():
		_send_rpc_reliable_pending()
		_send_rpc_pending_timer.start()
		
func _send_rpc_unreliable_pending():
	if not _taking_damages_pending.empty():
		var send_count = min(5, _taking_damages_pending.size())
		
		var chunk = []
		for i in range(send_count):
			chunk.append(_taking_damages_pending.pop_front())
		
		rpc_unreliable("_taking_damages", chunk)
		
func _send_rpc_reliable_pending():
	if not _member_deads_pending.empty():
		rpc("_on_members_dead", _member_deads_pending)
		_member_deads_pending.clear()
	
	if not _pending_modifier_send.empty():
		rpc("_set_modifiers", _pending_modifier_send)
		_pending_modifier_send.clear()
		
func _on_walking(_delta :float):
	pass
	
func _ajust_formation(pos :Vector3, delta :float):
	var members = get_members()
	var temp_form_offset = [ Vector3.ZERO ] if members.size() == 1 else _formation_offsets
	var basis :Basis = global_transform.basis
	
	for i in temp_form_offset.size():
		var offset :Vector3 = temp_form_offset[i] * formation_density
		_formation_positions[i] = (pos + basis.xform(offset))
		
	for idx in members.size():
		var m = members[idx]
		if m.iddle or m.range_mode:
			if visible:
				m.translation = m.translation.linear_interpolate(_formation_positions[idx], 5 * delta)
				
			else:
				m.translation = _formation_positions[idx]

func _attack_enemy_proccess(pos :Vector3, delta :float):
	# because this script run on both master & puppet
	# must check via is_instance_valid enemy
	if is_instance_valid(enemy):
		var look :Vector3 =  enemy.global_position
		look.y = pos.y
		
		if _is_still_in_melee_range(enemy):
			_on_enemy_in_melee_range(delta, pos, look)
			return
		
		if _is_still_in_attack_range(enemy):
			_on_enemy_in_range(delta, pos, look)
			return
			
	# prevent _on_enemy_unset fire
	# on each frame if already false
	if _has_enemy == false:
		return
		
	_has_enemy = false
	enemy = null
	_on_enemy_unset()
	
func _on_enemy_in_melee_range(_delta :float, _pos :Vector3, _enemy_pos :Vector3):
	pass
	
func _on_enemy_in_range(_delta :float, _pos :Vector3, _enemy_pos :Vector3):
	pass
	
func get_avg_member_pos(pos :Vector3) -> Vector3:
	var m :Array = get_members()
	if m.empty():
		return pos
	var npos = pos
	for i in m:
		npos += i.global_position
		
	return npos / (m.size() + 1)
	
func _set_floating_info_pos(pos :Vector3, _delta :float):
	# track floating ui
	if not _member_spawned or not floating_info:
		return
		
	floating_info.visible = visible and _current_visible
	if not floating_info.visible:
		return
		
	# validate and must not behind cam
	var _h = Vector3(0, 0.75, 0)
	if camera.is_position_behind(pos + _h):
		floating_info.visible = false
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
	
func get_iddle_members(all :bool = false) -> Array:
	var iddles = []
	for i in get_members():
		if i.iddle and (all or not i.is_bannerman):
			iddles.append(i)
			
	return iddles
	
func get_members(all :bool = false) -> Array:
	if not all:
		return _alive_members
	return _members
	
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
		
	if (current_tile in reinfoce_tiles):
		resurecting(false, false) # set false, no need to use RPC
		
	healing(false) # set false, no need to use RPC
	
func healing(use_rpc :bool = true):
	if _is_master or not use_rpc:
		_healing()
		return
		
	# call stop, tell master to stop from other peer
	rpc_id(get_network_master(), "_healing")
	
remote func _healing():
	if is_dead:
		return
	
	# heal first
	var datas :Array = []
	for idx in _members.size():
		var m = _members[idx]
		if m.is_dead:
			continue
			
		if m.hp >= member_max_hp:
			continue
			
		_members[idx].hp = int(min(_members[idx].hp + heal_amount, member_max_hp))
		datas.append([ _members[idx].hp, idx])
		
	if not datas.empty():
		rpc_unreliable("_taking_heal", datas)
		
func resurecting(all :bool = false, use_rpc :bool = true):
	if _is_master or not use_rpc:
		_resurecting(all)
		return
		
	# call stop, tell master to stop from other peer
	rpc_id(get_network_master(), "_resurecting", all)
	
remote func _resurecting(all :bool):
	if is_dead:
		return
		
	var list :Array = []
	
	# resurect the dead
	for idx in _members.size():
		var m = _members[idx]
		if m.is_dead:
			if all:
				list.append(idx)
				
			else:
				rpc("_resurect", [idx])
				return
				
	rpc("_resurect", list)
	
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
	
	var dmg :int = _get_damage_receive(amount)
	var m :SquadMember = _members[member_idx]
	m.attacked_by = attacked_by
	m.take_damage(dmg)
	
	_taking_damages_pending.append([dmg, m.hp, member_idx, from])
	
remotesync func _resurect(member_idxs :Array):
	for member_idx in member_idxs:
		if member_idx > _members.size() - 1 or member_idx == -1:
			continue
			
		var m :SquadMember = _members[member_idx]
		m.resurect()
		
		if not _alive_members.has(m):
			if m.is_bannerman:
				_alive_members.insert(0, m) # always first
				
			else:
				_alive_members.append(m)
			
		member_alive = _alive_members.size()
		
		emit_signal("on_squad_member_resurect", self, m)
	
remotesync func _taking_heal(datas :Array):
	for i in datas:
		var hp_remain :int = i[0]
		var member_idx :int = i[1]
		if member_idx > _members.size() - 1 or member_idx == -1:
			continue
			
		var m :SquadMember = _members[member_idx]
		m.hp = hp_remain
		
	emit_signal("on_squad_taking_heal", self)
	
remotesync func _taking_damages(datas :Array):
	var amount_total = 0
	
	for data in datas:
		var amount :int = data[0]
		var hp_remain :int = data[1]
		var member_idx :int = data[2]
		var from :NodePath = data[3]
		
		if member_idx > _members.size() - 1 or member_idx == -1:
			continue
			
		attacked_by = from
		
		if _is_master and not _heal_interupt:
			_heal_interupt = true
			
			# if on range engagement
			# and getting clap by melee enemy
			# change attention to them
			if _range_engagement:
				var s = get_node_or_null(attacked_by)
				if is_instance_valid(s):
					if _is_still_in_melee_range(s) and s.team != team:
						enemy = s
						_has_enemy = true
						_on_enemy_set()
						_range_engagement = false
						
		var m :SquadMember = _members[member_idx]
		m.hp = hp_remain
		
		amount_total += amount
		
	if visible and not _unit_audio.playing and amount_total > 0:
		_unit_audio.stream = hurt_sounds.pick_random()
		_unit_audio.play()
		
	emit_signal("on_squad_taking_damage", self, amount_total)
	
remotesync func _on_members_dead(datas :Array):
	var pos = global_position
	
	for i in datas:
		var member :SquadMember = _members[i[0]]
		member.attacked_by = i[1]
		member.set_dead()
		
		_alive_members.erase(member)
		member_alive = _alive_members.size()
		
		_on_member_dead(member)
		
		pos = member.global_position
		
	if not _blood_particle.emitting and visible and enable_blood:
		_blood_particle.translation = pos
		_blood_particle.emitting = true
		
	if visible and not _unit_audio.playing:
		_unit_audio.stream = death_sounds.pick_random()
		_unit_audio.play()
		
	if member_alive <= 0 and not is_dead:
		set_dead(false)
		
func _on_member_dead(member :SquadMember):
	emit_signal("on_squad_member_dead", self, member)

func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not is_dead:
		rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, 25 * delta)
		enemy = get_node_or_null(_puppet_enemy)
		_is_moving = _puppet_is_moving
		
func update_spotting():
	.update_spotting()
	
	_melee_tile_ranges = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.ARROW_DIRECTIONS, current_tile, 1
	) + [current_tile]
	
	# check if range melee tile connected and enable
	var temp :Array = _melee_tile_ranges.duplicate()
	for id in temp:
		if not nav.is_nav_enable(nav_layer, id):
			_melee_tile_ranges.erase(id)
			continue
			
		if not nav.is_point_connected(nav_layer, current_tile, id):
			_melee_tile_ranges.erase(id)
			
	if attack_range > 1:
		_attack_tile_ranges = TileMapUtils.get_adjacent_tiles(
			TileMapUtils.ARROW_DIRECTIONS, current_tile, attack_range
		)
		
		# remove melee tile from ranges
		for id in _melee_tile_ranges:
			_attack_tile_ranges.erase(id)
		
func _chase_on_iddle() -> bool:
	if is_instance_valid(chase_enemy):
		# stop the chase
		# continue scan area
		if chase_enemy.is_dead:
			chase_enemy = null
			return false
			
		if not _is_still_in_ranges(chase_enemy):
			chase_target()
			return true
			
	return false
	
# for active enemy spotting
func _on_global_tick():
	if _is_master and not _is_moving:
		
		# have task to chase enemy
		# go get them
		if _chase_on_iddle():
			return
			
		_scan_area()
		
func _scan_area():
	if unit_position.empty():
		return
		
	if _has_enemy:
		return
		
	# find in melee range first
	# then normal range
	if not _find_in_ranges(_melee_tile_ranges, true):
		_find_in_ranges(_attack_tile_ranges, false)
	
func _find_in_ranges(ranges :Array, validate_tile :bool) -> bool:
	if ranges.empty():
		return false
		
	for pos in ranges:
		if not unit_position.has(pos):
			continue
			
		var unit_positions :Array = unit_position[pos]
		if unit_positions.empty():
			continue
			
		var e = _get_enemy_in_position(unit_positions, validate_tile)
		if e[1]:
			enemy = e[0]
			_has_enemy = true
			_on_enemy_set()
			return true
			
	return false
	
func _get_enemy_in_position(datas :Array, validate_tile :bool) -> Array:
	for unit in datas:
		if not is_instance_valid(unit):
			continue
			
		if unit.is_dead or unit.team == team:
			continue
			
		if validate_tile:
			if unit.nav_layer != nav_layer:
				continue
			
		return [unit, true]
	
	return [null, false]
	
func _is_still_in_ranges(target) -> bool:
	if _has_range_weapon:
		if _is_still_in_attack_range(target):
			return true
			
	return _is_still_in_melee_range(target)
	
func get_current_tile_v3() -> Vector3:
	return _current_tile_v3
	
func is_in_melee_range(target) -> bool:
	return _is_still_in_melee_range(target)
	
func _is_still_in_melee_range(target):
	if target.is_dead:
		return false
		
	return target.current_tile in _melee_tile_ranges
	
func _is_still_in_attack_range(target) -> bool:
	if target.is_dead:
		return false
		
	return target.current_tile in _attack_tile_ranges
	
func _on_enemy_set():
	pass
	
func _on_enemy_unset():
	if _is_master:
		_scan_area()
	
func set_dead(use_rpc :bool = true):
	if is_dead:
		return
	
	if use_rpc:
		rpc("_set_dead")
	else:
		_set_dead()
		
	is_dead = true # safeguard, make faster
	
func on_dead():
	emit_signal("on_squad_dead", self)

remotesync func _set_dead():
	if is_dead:
		return
		
	is_dead = true
	on_dead()
	
# return [on cooldown, current time, total time]
func get_ability_cooldown() -> Array:
	return [
		not _ability_cooldown.is_stopped(), 
		_ability_cooldown.time_left, 
		_ability_cooldown.wait_time
	]
	
func start_ability_cooldown(v :float, use_rpc :bool = true):
	if _is_master or not use_rpc:
		_start_ability_cooldown(v)
		return
		
	# call _start_ability_cooldown, tell master to stop from other peer
	rpc_id(get_network_master(), "_start_ability_cooldown", v)
	
remote func _start_ability_cooldown(v :float):
	_ability_cooldown.wait_time = v
	_ability_cooldown.start()
	
# type :int, value :float, expired :float, icon_idx
# type buff debuff : 
# 0=melee speed, 1:range speed, 2:move speed, 3:damage receive, 4:melee damage, 5:range damage, value is percentage
func set_modifiers(datas :Array, remove_modifier :Array = []):
	for data in datas:
		var id = int(rand_range(-100, 100))
		data.append(id)
		
	_pending_modifier_send.append([datas, remove_modifier])
	
# type modifier
const modifier_melee_speed = 0
const modifier_range_speed = 1
const modifier_move_speed = 2
const modifier_damage_receive = 3
const modifier_melee_damage = 4
const modifier_range_damage = 5

var _modifiers :Dictionary = {} # {type:{id:value}}

remotesync func _set_modifiers(datas :Array):
	for i in datas:
		on_set_modifiers(i[0], i[1])
		
func on_set_modifiers(datas :Array, remove_modifier :Array):
	if not remove_modifier.empty():
		for type in remove_modifier:
			if _modifiers.has(type):
				_modifiers[type].clear()
				_update_multiplier(type)
			
		emit_signal("on_squad_modifier_clear", self)
		
	var additional :float = 1.0
	
	for i in datas:
		var type :int = i[0]
		var value :float = clamp(i[1], -0.99, 0.99)
		var expired :float = i[2]
		#var icon_idx :int = i[3]
		
		# waiting time minus? we dont add this nonesense
		if expired < 0: 
			continue
		
		var id :int = i.back()
		
		var _expired = Timer.new()
		_expired.one_shot = true
		_expired.autostart = false
		_expired.wait_time = expired + additional
		_expired.connect("timeout", self, "_on_buff_debuff_expired", [type, id, _expired])
		add_child(_expired)
		_expired.start()
		
		if not _modifiers.has(type):
			_modifiers[type] = {}
			
		_modifiers[type][id] = value
		
		_update_multiplier(type)
		additional += 1
		
		emit_signal("on_squad_set_modifier", self, i)
	
func _on_buff_debuff_expired(type :int, id:int, timer :Timer):
	if _modifiers[type].has(id):
		_modifiers[type].erase(id)
		
	_update_multiplier(type)
	timer.queue_free()
	
func _get_modifiers_value(type :int) -> float:
	var v = 0.0
	if not _modifiers.has(type):
		return v
		
	for values in _modifiers[type].values():
		v += values
	
	return clamp(v, -0.99, 0.99)
	
func _update_multiplier(type :int):
	match type:
		modifier_melee_speed:
			melee_attack_speed_mul = _get_modifiers_value(type)
		modifier_range_speed:
			range_attack_speed_mul = _get_modifiers_value(type)
		modifier_move_speed:
			speed_mul = _get_modifiers_value(type)
		modifier_damage_receive:
			damage_receive_mul = _get_modifiers_value(type)
		modifier_melee_damage:
			melee_damage_mul = _get_modifiers_value(type)
		modifier_range_damage:
			range_damage_mul = _get_modifiers_value(type)
			
func _get_attack_damage(type:int, unmod :int) -> int:
	match type:
		0:
			return int(unmod * (1.0 + melee_damage_mul))
		1:
			 # lest buff hero attack range
			var v = unmod * 4 if is_hero else unmod
			return int(v * (1.0 + range_damage_mul))
			
	return unmod
	
func _get_damage_receive(unmod :int) -> int:
	return int(max(unmod * (1.0 + damage_receive_mul), 1))
	
func _get_speed() -> float:
	return clamp(speed * (1.0 + speed_mul), MIN_MOVE_SPEED, MAX_MOVE_SPEED)
	
func _get_melee_attack_speed() -> float:
	var _v = 1.0 + melee_attack_speed_mul
	return clamp(melee_attack_speed / _v, MIN_MELEE_SPEED, MAX_MELEE_SPEED)
	
func _get_range_attack_speed() -> float:
	var spd = range_attack_speed
	var _v = 1.0 + range_attack_speed_mul
	
	if rapid_fire_mode:
		var count = max(member_alive, 1)
		spd = clamp(range_attack_speed / count * 1.1, MIN_RANGE_SPEED, MAX_RANGE_SPEED)
		spd += rand_range(-0.03, 0.03)
		
	return clamp(spd / _v, MIN_RANGE_SPEED, MAX_RANGE_SPEED)
	
func _rotate_to_look(delta :float, pos :Vector3, to :Vector3, dir_to :Vector3):
	# look at enemy position
	if _can_look_at(dir_to):
		var t:Transform = transform.looking_at(to, Vector3.UP)
		transform = transform.interpolate_with(t, turning_speed * delta)
		
func _can_look_at(dir :Vector3) -> bool:
	if dir.length() > 0.001:
		var dot = abs(dir.dot(Vector3.UP))
		return dot < 0.999
		
	return false
