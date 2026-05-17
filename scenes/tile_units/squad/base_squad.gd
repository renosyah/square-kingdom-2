extends BaseTileUnit
class_name BaseSquad

signal on_squad_taking_damage(squad, amount)

export var member_scene :PackedScene
export var has_range_weapon :bool
export var can_attack :bool
export var turning_speed :float = 8
export var attack_speed :float = 0.8
export var formation_density :float = 0.35

export var member_headgear :PackedScene
export var member_armor :PackedScene
export var member_shield :PackedScene
export var member_melee_weapon :PackedScene
export var member_range_weapon :PackedScene

export var member_hp :int = 100
export var member_max_hp :int = 100
export var god_mode :bool = false

puppet var _puppet_rotation_y :float
puppet var _puppet_enemy :NodePath
puppet var _puppet_is_moving :bool

var _member_alive :int
var _formation_offsets :Array = [] # [Vector3]
var _formation_positions :Array = [] # [Vector3]
var _members :Array = [] # [SquadMember]
var _melee_ranges :Array = []

var _attack_timer :Timer
var _path_indicator :Spatial

func _ready():
	connect("tree_exiting", self, "_tree_exiting")
	
	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.autostart = false
	_attack_timer.wait_time = 0.8
	add_child(_attack_timer)
	
	_path_indicator = preload("res://scenes/tile_units/squad/squad_path_indicator/squad_path_indicator.tscn").instance()
	add_child(_path_indicator)
	_path_indicator.set_as_toplevel(true)
	
	_init_formations()
	_spawn_members()
	
func _init_formations():
	pass
	
func _spawn_members():
	for idx in _formation_positions.size():
		var member :SquadMember = member_scene.instance()
		member.squad = self
		member.name = "%s_member_%s" % [name, idx]
		
		member.headgear = member_headgear
		member.armor = member_armor
		member.shield = member_shield
		member.melee_weapon = member_melee_weapon
		member.range_weapon = member_range_weapon
		
		member.hp = member_hp
		member.max_hp = member_max_hp
		
		member.connect("attack_performed", self, "_on_member_attack_performed")
		member.connect("on_member_dead", self, "_on_member_dead")
		
		add_child(member)
		member.set_as_toplevel(true)
		member.translation = _formation_positions[idx]
		_members.append(member)
		
		_member_alive += 1
		
func _on_member_attack_performed(member :SquadMember, target :SquadMember, target_member_idx :int, attack_damage :int):
	if not _is_master:
		return
		
	# why use target.squad?
	# if we were use enemy (squad)
	# the pointer of enemy will be gone/replace
	# this signal is called on diffrent event so...
	if is_instance_valid(target):
		target.squad.take_damage(attack_damage, target_member_idx)
		
func _on_member_dead(member :SquadMember):
	rpc("_on_member_dead_sync", member.get_path())
	
remotesync func _on_member_dead_sync(p :NodePath):
	var member = get_node_or_null(p)
	if not is_instance_valid(member):
		return
		
	if _members.has(member):
		member.visible = false
		_member_alive -= 1
		
func _tree_exiting():
	for i in _members:
		i.queue_free()
		
func _on_current_tile_updated(from_id :Vector2, to_id :Vector2):
	._on_current_tile_updated(from_id, to_id)
	
	_path_indicator.translation = nav.get_pos_v3(current_tile)
	
func sync_update() -> void:
	.sync_update()
	
	if not is_dead and _is_master and _is_online:
		rset_unreliable("_puppet_is_moving", _is_moving)
		rset_unreliable("_puppet_rotation_y", global_rotation.y)
		
		if _has_enemy:
			rset_unreliable("_puppet_enemy", enemy.get_path())
			
		else:
			rset_unreliable("_puppet_enemy", NodePath(""))
		
func moving(delta :float) -> void:
	.moving(delta)
	
	var pos :Vector3 = global_position
	var basis :Basis = global_transform.basis
	
	for i in _formation_offsets.size():
		var offset :Vector3 = _formation_offsets[i] * formation_density
		_formation_positions[i] = (pos + basis.xform(offset))
		
	var idx = 0
	for m in _members:
		if not is_instance_valid(m):
			continue
			
		if m.iddle:
			m.translation =  m.translation.linear_interpolate(_formation_positions[idx], 5 * delta)
			
		idx += 1
		
func get_member_index(m :SquadMember) -> int:
	return _members.find(m)
		
func pick_member(iddle_one :bool = true) -> SquadMember:
	if not iddle_one:
		return null if _members.empty() else _members.pick_random()
		
	var iddles = get_iddle_member()
	return null if iddles.empty() else iddles.pick_random()
	
func pick_closes(pos :Vector3, iddle_one :bool = true) -> SquadMember:
	var iddles = get_iddle_member() if iddle_one else _members
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
	
func get_iddle_member() -> Array:
	var iddles = []
	for i in _members:
		if i.iddle and not i.is_dead:
			iddles.append(i)
			
	return iddles
	
func _on_no_enemy():
	._on_no_enemy()
	
	if not _attack_timer.is_stopped():
		_attack_timer.stop()
		
func _is_in_melee_range(target):
	return target.current_tile in _melee_ranges
	
func take_damage(amount :int, member_idx :int):
	if is_dead:
		return
		
	var m :SquadMember = _members[member_idx]
	if not is_instance_valid(m):
		return
		
	m.take_damage(amount)
	
	rpc_unreliable("_taking_damage", amount)
	
	if _member_alive <= 0:
		set_dead()
		
remotesync func _taking_damage(amount :int):
	emit_signal("on_squad_taking_damage", self, amount)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not is_dead:
		rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, 25 * delta)
		enemy = get_node_or_null(_puppet_enemy)
		_is_moving = _puppet_is_moving
