extends Equipment
class_name RangeWeapon

signal on_hit(projectile_pos)

export var projectile :PackedScene
export var attack_damage :int
export var show_on_stored :bool = true
export var bonus_damage :int = 6 # times of damage bonus

export var walk_animation :String = "walk"
export var ready_animation :String = "iddle"
export var attack_animation :String = "shot_range_weapon"

var _pools :Array = []

func _ready():
	connect("tree_exiting", self, "_on_tree_exiting")
	
	if Global.current_root:
		_prepare_pool()
		
func get_attack_damage(enemy_squad_attribute :Array) -> int:
	return attack_damage
	
func _prepare_pool():
	for i in 3:
		var arrow :BaseProjectile = projectile.instance()
		arrow.connect("on_reach", self ,"_on_projectile_reach", [arrow])
		Global.current_root.add_child(arrow)
		_pools.append(arrow)

func _get_pool() -> BaseProjectile:
	for i in _pools:
		if i.is_ready():
			return i
			
	var arrow :BaseProjectile = projectile.instance()
	arrow.connect("on_reach", self ,"_on_projectile_reach", [arrow])
	Global.current_root.add_child(arrow)
	_pools.append(arrow)
	return arrow

func _on_projectile_reach(arrow):
	emit_signal("on_hit", arrow.global_position)
	
func _on_tree_exiting():
	for i in _pools:
		i.queue_free()
	
func pull():
	pass
	
func release():
	pass
	
func shot_projectile(to :Vector3, v :bool):
	var arrow = _get_pool()
	arrow.visible = v
	arrow.translation = global_position
	arrow.to = to + Vector3.ONE * rand_range(-0.5,0.5)
	arrow.launch()
	
