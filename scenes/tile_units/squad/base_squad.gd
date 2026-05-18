extends BaseTileUnit
class_name BaseSquad

signal on_squad_taking_damage(squad, amount)

const walk_sounds = [
	preload("res://assets/sounds/walks/walk_1.wav"),
	preload("res://assets/sounds/walks/walk_2.wav"),
	preload("res://assets/sounds/walks/walk_3.wav")
]

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
export var member_material :SpatialMaterial

export var member_hp :int = 100
export var member_max_hp :int = 100

# MUST SET
var squad_icon :StreamTexture
var camera :Camera
var overlay_ui :Control

puppet var _puppet_rotation_y :float
puppet var _puppet_enemy :NodePath
puppet var _puppet_is_moving :bool

var _member_alive :int
var _formation_offsets :Array = [] # [Vector3]
var _formation_positions :Array = [] # [Vector3]
var _members :Array = [] # [SquadMember]
var _melee_ranges :Array = []

var _audio :AudioStreamPlayer3D
var _attack_timer :Timer
var _walk_timer :Timer
var _path_indicator :Spatial
var _floating_info :FloatingSquadInfo

func _ready():
	connect("tree_exiting", self, "_tree_exiting")
	
	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.autostart = false
	_attack_timer.wait_time = attack_speed
	add_child(_attack_timer)
	
	_walk_timer = Timer.new()
	_walk_timer.one_shot = true
	_walk_timer.autostart = false
	_walk_timer.wait_time = 0.63
	add_child(_walk_timer)

	_audio = AudioStreamPlayer3D.new()
	_audio.unit_db = 5
	add_child(_audio)
	
	_path_indicator = preload("res://assets/squad_path_indicator/squad_path_indicator.tscn").instance()
	_path_indicator.material = member_material
	add_child(_path_indicator)
	_path_indicator.set_as_toplevel(true)
	
	yield(get_tree().create_timer(0.5),"timeout")
	
	_init_formations()
	_spawn_members()
	
func _init_formations():
	pass
	
func _spawn_members():
	var pos :Vector3 = global_position
	var basis :Basis = global_transform.basis
	
	for idx in _formation_offsets.size():
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
		
		member.connect("attack_performed", self, "_on_member_attack_performed")
		member.connect("on_member_dead", self, "_on_member_dead")
		
		add_child(member)
		member.set_as_toplevel(true)
		member.translation = _formation_positions[idx]
		_members.append(member)
		
		_member_alive += 1
		
	_floating_info = preload("res://assets/user_interface/icons/floating_squad_info/floating_squad_info.tscn").instance()
	_floating_info.name = "info_%s" % name
	_floating_info.color = color
	_floating_info.icon = squad_icon
	_floating_info.max_hp = get_members_total_hp()
	overlay_ui.add_child(_floating_info)
	
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
	if _members.has(member):
		member.visible = false
		_member_alive -= 1
		
func _tree_exiting():
	for i in _members:
		i.queue_free()
		
	_floating_info.queue_free()
	
func _on_current_tile_updated(from_id :Vector2, to_id :Vector2):
	._on_current_tile_updated(from_id, to_id)
	
	_path_indicator.visible = (nav != null)
	
	if _path_indicator.visible:
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
			
		if m.is_dead:
			continue
			
		if m.iddle or m.range_mode:
			m.translation = m.translation.linear_interpolate(_formation_positions[idx], 5 * delta)
			
		idx += 1
		
	if _is_moving and _walk_timer.is_stopped():
		_walk_timer.start()
		_audio.stream = walk_sounds.pick_random()
		_audio.play()
		
	# track floating ui
	if not overlay_ui.visible or not _floating_info:
		return
		
	_floating_info.visible = _current_visible
	if not _floating_info.visible:
		return
		
	var _pos = pos + Vector3(0, 0.75, 0)
	if camera.is_position_behind(_pos):
		return
		
	var screen_pos = camera.unproject_position(_pos)
	_floating_info.rect_global_position = screen_pos - _floating_info.rect_pivot_offset
	
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
	
func get_members() -> Array:
	var alives = []
	for i in _members:
		if not i.is_dead:
			alives.append(i)
			
	return alives
	
func get_members_total_hp() -> int:
	var total = 0
	var m = get_members()
	for i in m:
		total += i.hp
		
	return total
	
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
	_floating_info.update_bar(get_members_total_hp())
	emit_signal("on_squad_taking_damage", self, amount)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not is_dead:
		rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, 25 * delta)
		enemy = get_node_or_null(_puppet_enemy)
		_is_moving = _puppet_is_moving
