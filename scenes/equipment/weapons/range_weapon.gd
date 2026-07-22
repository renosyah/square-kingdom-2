extends Equipment
class_name RangeWeapon

signal on_hit(target_tile, dmg)

const bow_sounds = [
	preload("res://assets/sounds/weapons/bow_release_1.wav"),
	preload("res://assets/sounds/weapons/bow_release_2.wav")
]

export var projectile :PackedScene
export var attack_damage :int
export var show_on_stored :bool = true
export var bonus_damage :float = 0.15

export var walk_animation :String = "walk"
export var ready_animation :String = "iddle"
export var attack_animation :String = "shot_range_weapon"
export var accuration :float = 0.75

export var is_indirect :bool = true
export var has_splash_damage :bool = false

var is_master :bool

var _pools :Array = []

func _ready():
	connect("tree_exiting", self, "_on_tree_exiting")
	
	if Global.current_root:
		_prepare_pool()
		
func get_projectile_damage(target, enemy_squad_attribute :Array) -> int:
	return attack_damage
	
func _create_projectile() -> BaseProjectile:
	var arrow :BaseProjectile = projectile.instance()
	Global.current_root.add_child(arrow)
	return arrow
	
func _prepare_pool():
	for i in 3:
		_pools.append(_create_projectile())

func _get_pool() -> BaseProjectile:
	for i in _pools:
		if i.is_ready():
			return i
			
	var p = _create_projectile()
	_pools.append(p)
	return p

func _on_tree_exiting():
	for i in _pools:
		i.queue_free()
	
func get_sound() -> AudioStream:
	return bow_sounds.pick_random()
	
func pull():
	pass
	
func release():
	pass
	
func shot_projectile(target_tile :Vector2, dmg :int, to :Vector3, v :bool):
	var arrow = _get_pool()
	arrow.visible = v
	arrow.translation = global_position
	arrow.to = to + Vector3.ONE * rand_range(-0.25,0.25)
	arrow.launch()
	
	if is_master:
		yield(arrow, "on_reach")
		emit_signal("on_hit", target_tile, dmg)
	
