extends Equipment
class_name RangeWeapon

signal on_hit(projectile_pos)

export var projectile :PackedScene
export var attack_damage :int
export var show_on_stored :bool = true

export var walk_animation :String = "walk"
export var ready_animation :String = "iddle"
export var attack_animation :String = "shot_range_weapon"

var _scene_menu
var _pools :Array = []

func _ready():
	connect("tree_exiting", self, "_on_tree_exiting")
	
	var last_index = get_tree().get_root().get_child_count() - 1
	_scene_menu = get_tree().get_root().get_child(last_index)
	_prepare_pool()
	
func _prepare_pool():
	for i in 3:
		var arrow :BaseProjectile = projectile.instance()
		arrow.connect("on_reach", self ,"_on_projectile_reach", [arrow])
		_scene_menu.add_child(arrow)
		_pools.append(arrow)

func _get_pool() -> BaseProjectile:
	for i in _pools:
		if not i.visible:
			return i
			
	var arrow :BaseProjectile = projectile.instance()
	arrow.connect("on_reach", self ,"_on_projectile_reach", [arrow])
	_scene_menu.add_child(arrow)
	_pools.append(arrow)
	return arrow

func _on_projectile_reach(arrow):
	emit_signal("on_hit", arrow.global_position)
	yield(get_tree().create_timer(1),"timeout")
	arrow.visible = false
	
func _on_tree_exiting():
	for i in _pools:
		i.queue_free()
	
func pull():
	pass
	
func release():
	pass
	
func shot_projectile(to :Vector3):
	var arrow = _get_pool()
	arrow.translation = global_position
	arrow.to = to + Vector3.ONE * rand_range(-0.5,0.5)
	arrow.launch()
	
