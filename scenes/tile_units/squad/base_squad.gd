extends BaseTileUnit
class_name BaseSquad

export var member_scene :PackedScene
export var has_range_weapon :bool
export var attack_damage :int
export var can_attack :bool
export var turning_speed :float = 8
export var attack_speed :float = 0.8
export var formation_density :float = 0.35

puppet var _puppet_rotation_y :float
puppet var _puppet_enemy :NodePath

var _formation_offsets :Array = [] # [Vector3]
var _formation_positions :Array = [] # [Vector3]
var _members :Array = [] # [SquadMember]
var _melee_ranges :Array = []

var _attack_timer :Timer

func _ready():
	connect("tree_exiting", self, "_tree_exiting")
	
	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.autostart = false
	_attack_timer.wait_time = 0.8
	add_child(_attack_timer)
	
	_init_formations()
	_spawn_members()
	
func _init_formations():
	pass
	
func _spawn_members():
	for idx in _formation_positions.size():
		var member :SquadMember = member_scene.instance()
		member.squad = self
		member.name = "%s_member_%s" % [name, idx]
		member.connect("attack_performed", self, "_on_member_attack_performed")
		add_child(member)
		member.set_as_toplevel(true)
		member.translation = _formation_positions[idx]
		_members.append(member)
		
func _on_member_attack_performed(member :SquadMember, enemy :SquadMember):
	if _is_master:
		enemy.squad.take_damage(attack_damage)
		
func _tree_exiting():
	for i in _members:
		i.queue_free()
	
func sync_update() -> void:
	.sync_update()
	
	if not is_dead and _is_master and _is_online:
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
		
func _on_enemy_in_range(delta :float, pos :Vector3, enemy_pos :Vector3):
	._on_enemy_in_range(delta, pos, enemy_pos)
	
	# align Y
	var look :Vector3 = enemy_pos
	look.y = pos.y
	
	# look at enemy position
	var t:Transform = transform.looking_at(look, Vector3.UP)
	transform = transform.interpolate_with(t, turning_speed * delta)
	
	var dir_to :Vector3 = pos.direction_to(look)
	var foward_dir :Vector3 = (-global_transform.basis.z)
	var is_align :bool = foward_dir.dot(dir_to) > 0.85
	
	if not can_attack:
		return
		
	if not is_align or not _attack_timer.is_stopped():
		return
		
	_attack_timer.wait_time = attack_speed
	_attack_timer.start()
	
	# assign the target of enemy squad member
	var iddles :Array = get_iddle_member()
	
	if _is_in_melee_range(enemy):
		var m :SquadMember = iddles.pick_random()
		if not is_instance_valid(m):
			return
			
		# tell to attack 
		# use melee weapon
		var enemy_member = enemy.pick_closes(m.global_position)
		if is_instance_valid(enemy_member):
			m.enemy = enemy_member
			m.melee_attack()
		return
		
	if has_range_weapon:
		var count = randi() % iddles.size()
		for _i in count:
			var m :SquadMember = iddles.pick_random()
			if not is_instance_valid(m):
				continue
				
			# tell to attack 
			# use range weapon
			var enemy_member = enemy.pick_member()
			if is_instance_valid(enemy_member):
				m.enemy = enemy_member
				m.range_attack()
				
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
		if i.iddle:
			iddles.append(i)
			
	return iddles
	
func _on_no_enemy():
	._on_no_enemy()
	
	if not _attack_timer.is_stopped():
		_attack_timer.stop()
		

func _is_in_melee_range(target):
	return target.current_tile in _melee_ranges
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not is_dead:
		rotation.y = lerp_angle(rotation.y, _puppet_rotation_y, 25 * delta)
		enemy = get_node_or_null(_puppet_enemy)
