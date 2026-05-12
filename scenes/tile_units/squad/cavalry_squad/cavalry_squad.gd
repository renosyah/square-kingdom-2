extends BaseSquad

export var charge_damage :int
export var charge_required :int = 3

var _charges :int
var _ready_charge :bool

func _init_formations():
	._init_formations()
	
	# flag carrier were back
	_formation_offsets = [
		Vector3.FORWARD, 
		Vector3.LEFT, Vector3.RIGHT, 
		Vector3.BACK
	]
	_formation_positions = _formation_offsets.duplicate()
	
func _move_to(tile_id :Vector2):
	._move_to(tile_id)
	
	_ready_charge = false
	
func _move_to_next_path(delta :float, pos :Vector3, to :Vector3):
	#._move_to_next_path(delta, pos, to)
	
	# align Y
	var look :Vector3 = to
	look.y = pos.y
	
	var t:Transform = transform.looking_at(look, Vector3.UP)
	transform = transform.interpolate_with(t, turning_speed * delta)
	translation += -transform.basis.z * speed * delta
	
func _on_enemy_in_range(delta :float, pos :Vector3, enemy_pos :Vector3):
	#._on_enemy_in_range(delta, pos, enemy_pos)
	
	# align Y
	var look :Vector3 = enemy_pos
	look.y = pos.y
	
	# look at enemy position
	var t:Transform = transform.looking_at(look, Vector3.UP)
	transform = transform.interpolate_with(t, 25 * delta)
	
	if _attack_timer.is_stopped():
		_attack_timer.start()
		
		# randomly pick own squad member
		var m :SquadMember = pick_member()
		if not is_instance_valid(m):
			return
			
		# assign the target of enemy squad member
		m.enemy = enemy.pick_member(false)
		
		if _is_in_melee_range(enemy):
			# tell to attack 
			# use melee weapon
			m.melee_attack()
			return
			
		if has_range_weapon:
			# tell to attack 
			# use range weapon
			m.range_attack()
			
func update_spotting():
	.update_spotting()
	
	_melee_ranges = [current_tile]
	
func _on_current_tile_updated(from_id :Vector2, to_id :Vector2):
	._on_current_tile_updated(from_id, to_id)
	
	# if there are chases enemy
	# and cav travel more than enough
	if is_instance_valid(chase_enemy):
		_charges = int(clamp(_charges + 1, 0, charge_required))
		
	if (_charges >= charge_required) and not _ready_charge:
		# make ready lances
		# this _ready_charge is here 
		# to not trigger multiple time
		_ready_charge = true
		
		
func _on_finish_travel(from_id :Vector2, to_id :Vector2):
	._on_finish_travel(from_id, to_id)
	
	if not is_instance_valid(chase_enemy):
		return
		
	var is_impact :bool = (chase_enemy.current_tile == current_tile) and (_charges >= charge_required)
	if not is_impact:
		return
		
	chase_enemy.take_damage(charge_damage + attack_damage)
	_ready_charge = false
	







