extends SquadMember

const sword_sounds = [
	preload("res://assets/sounds/weapons/sword_1.wav"),
	preload("res://assets/sounds/weapons/sword_2.wav"),
	preload("res://assets/sounds/weapons/sword_3.wav"),
	preload("res://assets/sounds/weapons/sword_4.wav"),
	preload("res://assets/sounds/weapons/sword_5.wav"),
	preload("res://assets/sounds/weapons/sword_6.wav")
]
const bow_sounds = [
	preload("res://assets/sounds/weapons/bow_release_1.wav"),
	preload("res://assets/sounds/weapons/bow_release_2.wav")
]

onready var leg_animation_state = $leg_animation_tree.get("parameters/playback")
onready var body_animation_state = $body_animation_tree.get("parameters/playback")
onready var tween = $Tween

onready var weapon_holder = $pivot/body/hand_r/weapon_holder
onready var shield_holder = $pivot/body/hand_l/shield_holder
onready var range_weapon_holder = $pivot/body/hand_r/range_weapon_holder

onready var range_storage_holder = $pivot/body/range_storage_holder
onready var melee_storage_holder = $pivot/body/melee_storage_holder
onready var shield_storage_holder = $pivot/body/shield_storage_holder

var _headgear :Equipment
var _armor :Equipment
var _shield :Equipment
var _melee_weapon :MeleeWeapon
var _range_weapon :RangeWeapon

onready var auto_iddle_timer = $auto_iddle_timer
onready var combat_sound = $combat_sound

onready var uniforms = [
	$pivot/body/body,
	$pivot/body/hand_r/hand_r,
	$pivot/body/hand_l/hand_l,
	$pivot/leg_r/leg_r,
	$pivot/leg_l/leg_l
]

var _last_pos :Vector3

func _ready():
	if melee_weapon:
		var w = melee_weapon.instance()
		weapon_holder.add_child(w)
		melee_storage_holder.add_child(w.duplicate())
		_melee_weapon = w
		
	if shield:
		var w = shield.instance()
		shield_holder.add_child(w)
		shield_storage_holder.add_child(w.duplicate())
		_shield = w
	
	if range_weapon:
		var w = range_weapon.instance()
		range_weapon_holder.add_child(w)
		range_storage_holder.add_child(w.duplicate())
		_range_weapon = w
		
	if range_weapon:
		prepare_range_weapon()
		
	else:
		prepare_melee_weapon()
	
	for i in uniforms:
		var m :MeshInstance = i
		m.set_surface_material(0, material)
	
func prepare_melee_weapon():
	.prepare_melee_weapon()
	
	if melee_mode:
		return
		
	melee_mode = true
	range_mode = false
	
	weapon_holder.visible = true
	shield_holder.visible = true
	range_weapon_holder.visible = false
	
	range_storage_holder.visible = true
	melee_storage_holder.visible = false
	shield_storage_holder.visible = false

func prepare_range_weapon():
	.prepare_range_weapon()
	
	if range_mode:
		return
		
	melee_mode = false
	range_mode = true
	
	weapon_holder.visible = false
	shield_holder.visible = false
	range_weapon_holder.visible = true
	
	range_storage_holder.visible = false
	melee_storage_holder.visible = true
	shield_storage_holder.visible = true
	
func melee_attack():
	#.melee_attack()
	
	if is_dead or not iddle:
		return
		
	enemy_assign = true
	iddle = false
	
	_last_pos = global_position
	
	prepare_melee_weapon()
	
	var _dir = global_position.direction_to(enemy.global_position)
	if _dir.length() > 0.001:
		var dot = abs(_dir.dot(Vector3.UP))
		if dot < 0.999:
			look_at(enemy.global_position, Vector3.UP)
	
	tween.interpolate_property(self, "translation", global_position, enemy.global_position, 0.8)
	tween.start()
	yield(tween,"tween_completed")
	
	body_animation_state.travel(_melee_weapon.attack_animation)
	auto_iddle_timer.start()
	
func _on_melee_attack_performed():
	combat_sound.stream = sword_sounds.pick_random()
	combat_sound.play()
	
	tween.interpolate_property(self, "translation", global_position, _last_pos, 1.2)
	tween.start()
	yield(tween,"tween_completed")
	
	emit_signal("attack_performed", self, enemy, target_idx, _melee_weapon.attack_damage)
	
	iddle = true
	enemy = null
	enemy_assign = false
	auto_iddle_timer.stop()
	
func range_attack():
	#.range_attack()
	
	if is_dead or not iddle:
		return
		
	enemy_assign = true
	iddle = false
	
	prepare_range_weapon()
	look_at(enemy.global_position, Vector3.UP)
	
	body_animation_state.travel(_range_weapon.attack_animation)
	auto_iddle_timer.start()
	
func _on_pulling_bow():
	_range_weapon.pull()
	
func _on_release_bow():
	_range_weapon.release()
	
	combat_sound.stream = bow_sounds.pick_random()
	combat_sound.play()
	
	if not is_instance_valid(enemy):
		return
		
	var arrow = preload("res://scenes/projectiles/arrow.tscn").instance()
	add_child(arrow)
	arrow.translation = global_position
	arrow.to = enemy.global_position + Vector3.ONE * rand_range(-0.5,0.5)
	arrow.launch()
	
	var _enemy_pos :Vector3 = enemy.global_position
	yield(arrow,"on_reach")
	
	if arrow.global_position.distance_to(_enemy_pos) < 0.6:
		emit_signal("attack_performed", self, enemy, target_idx, _range_weapon.attack_damage)
		
	yield(get_tree().create_timer(1),"timeout")
	arrow.queue_free()
	
func _on_range_attack_performed():
	
	iddle = true
	enemy = null
	enemy_assign = false
	auto_iddle_timer.stop()

func moving(delta :float):
	.moving(delta)
	
	if is_dead:
		return
		
	if iddle:
		if range_mode:
			body_animation_state.travel(
				_range_weapon.walk_animation if squad.is_moving() else _range_weapon.ready_animation
			)
			
		if melee_mode:
			body_animation_state.travel(
				_melee_weapon.walk_animation if squad.is_moving() else _melee_weapon.ready_animation
			)
		
	leg_animation_state.travel(
		"walk" if squad.is_moving() or (enemy_assign and melee_mode) else "iddle"
	)

func dead():
	.dead()
	
	visible = false

func _on_auto_iddle_timer_timeout():
	iddle = true
	enemy = null
	enemy_assign = false
