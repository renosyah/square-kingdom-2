extends BaseTileUnit
class_name Squad

export var has_range_weapon :bool

var _members :Array = [] # [SquadMember]
var _melee_ranges :Array = []

var _attack_timer :Timer

func _ready():
	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.autostart = false
	_attack_timer.wait_time = 0.5
	add_child(_attack_timer)

func _on_enemy_in_range(delta :float, pos :Vector3, enemy_pos :Vector3):
	._on_enemy_in_range(delta, pos, enemy_pos)
	
	# align Y
	var look :Vector3 = enemy_pos
	look.y = pos.y
	
	# look at enemy position
	var t:Transform = transform.looking_at(look, Vector3.UP)
	transform = transform.interpolate_with(t, 25 * delta)
	
	var dir_to :Vector3 = pos.direction_to(look)
	var foward_dir :Vector3 = (-global_transform.basis.z)
	var is_align :bool = foward_dir.dot(dir_to) > 0.85
	
	if is_align and _attack_timer.is_stopped():
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
	
func pick_member(iddle_one :bool = true) -> SquadMember:
	if not iddle_one:
		return _members.pick_random()
		
	var iddles = []
	for i in _members:
		if i.iddle:
			iddles.append(i)
			
	return null if iddles.empty() else iddles.pick_random()
	
func _on_no_enemy():
	._on_no_enemy()
	
	if not _attack_timer.is_stopped():
		_attack_timer.stop()
		
func update_spotting():
	.update_spotting()
	
	_melee_ranges = TileMapUtils.get_adjacent_tiles(
		TileMapUtils.get_directions(), current_tile, 1
	)
	
func _is_in_melee_range(target):
	return target.current_tile in _melee_ranges
