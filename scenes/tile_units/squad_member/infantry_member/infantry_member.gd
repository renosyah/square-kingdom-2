extends SquadMember
class_name InfantryMember

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

onready var headgear_holder = $pivot/body/head
onready var armor_holder = $pivot/body
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

onready var uniforms = [
	$pivot/body/body,
	$pivot/body/hand_r/hand_r,
	$pivot/body/hand_l/hand_l,
	$pivot/leg_r/leg_r,
	$pivot/leg_l/leg_l
]

var _last_pos :Vector3
var _current_anim_body :String
var _current_anim_walk :String

func _ready():
	apply_equipment()
	_current_anim_walk = "on_sadle" if on_horse else "iddle"
	leg_animation_state.travel(_current_anim_walk)
	
func resurect():
	.resurect()
	
	if _headgear:
		_headgear.visible = true
		
	if _armor:
		_armor.visible = true
		
		
	_current_anim_body = "iddle"
	_current_anim_walk = "on_sadle" if on_horse else "iddle"
	
	body_animation_state.start(_current_anim_body)
	leg_animation_state.start(_current_anim_walk)
	
func apply_equipment():
	# remove currently equiped
	var current = [_headgear, _melee_weapon, _shield, _armor, _range_weapon]
	for i in current:
		if is_instance_valid(i):
			i.queue_free()
			
	# remove currently stored
	var current_storeds = [melee_storage_holder, shield_storage_holder, range_storage_holder]
	for current_stored in current_storeds:
		for i in current_stored.get_children():
			current_stored.remove_child(i)
			i.queue_free()
			
	if headgear:
		var w = headgear.instance()
		headgear_holder.add_child(w)
		_headgear = w
		
	if armor:
		var w = armor.instance()
		armor_holder.add_child(w)
		_armor = w
		
	if melee_weapon:
		var w = melee_weapon.instance()
		weapon_holder.add_child(w)
		
		if w.show_on_stored:
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
		
		if w.show_on_stored:
			range_storage_holder.add_child(w.duplicate())
			
		_range_weapon = w
		
	for i in uniforms:
		var m :MeshInstance = i
		m.set_surface_material(0, material)
	
	if range_weapon:
		prepare_range_weapon()
		_current_anim_body = _range_weapon.ready_animation
		body_animation_state.travel(_current_anim_body)
		return
		
	if melee_weapon:
		prepare_melee_weapon()
		_current_anim_body = _melee_weapon.ready_animation
		body_animation_state.travel(_current_anim_body)
		
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
	_look_at(enemy.global_position)
	
	if not on_horse:
		var pos = enemy.global_position
		var y_pos = pos.y
		pos.y = global_position.y
		
		var offset = pos.direction_to(global_position) * 0.35
		tween.interpolate_property(self, "translation", global_position, pos + offset, 0.8)
		tween.start()
		yield(tween,"tween_completed")
		global_position.y = y_pos
		
	_current_anim_body = _melee_weapon.attack_animations.pick_random()
	body_animation_state.travel(_current_anim_body)
	auto_iddle_timer.start()
	
func _on_melee_attack_performed():
	if not squad:
		return
		
	if squad.visible:
		_combat_sound.stream = sword_sounds.pick_random()
		_combat_sound.play()
	
	if not on_horse:
		global_position.y = _last_pos.y
		tween.interpolate_property(self, "translation", global_position, _last_pos, 1.2)
		tween.start()
		yield(tween,"tween_completed")
		
	if is_instance_valid(enemy):
		var melee_dmg = _melee_weapon.get_attack_damage(enemy.squad.squad_attribute)
		emit_signal("on_set_damage_to_target", self, enemy, target_idx, melee_dmg)
		
		if _melee_weapon.has_splash_damage:
			var target_tile = enemy.squad.current_tile
			emit_signal("on_set_damage_to_tile", self, target_tile, melee_dmg * 0.5)
	
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
	_look_at(enemy.global_position)
	
	_current_anim_body = _range_weapon.attack_animation
	body_animation_state.travel(_current_anim_body)
	auto_iddle_timer.start()
	
func _on_pulling_bow():
	_range_weapon.pull()
	
func _on_release_bow():
	_range_weapon.release()
	
	if squad.visible:
		_combat_sound.stream = bow_sounds.pick_random()
		_combat_sound.play()
		
	if not is_instance_valid(enemy):
		return
		
	if not is_instance_valid(enemy.squad):
		return
		
	var target_tile = enemy.squad.current_tile
	
	if is_instance_valid(enemy):
		_range_weapon.shot_projectile(enemy.global_position, enemy.visible or squad.visible)
		yield(_range_weapon,"on_hit")
		
	emit_signal("on_set_damage_to_tile", self, target_tile, _range_weapon.attack_damage)
	
func _on_range_attack_performed():
	iddle = true
	enemy = null
	enemy_assign = false
	
	auto_iddle_timer.stop()
	
func take_damage(amount :int):
	.take_damage(amount)
	
	if is_dead:
		return
		
	# little bit mechanism of losing
	# gear on damages
	var ratio = float(hp) / float(max_hp)
	if ratio > 0.5:
		return
		
	if randf() < 0.6 and _headgear:
		_headgear.visible = false
		return
		
	if randf() < 0.4 and _armor:
		_armor.visible = false
		
func moving(delta :float):
	.moving(delta)
	
	if is_dead or not squad.visible:
		return
		
	var _is_moving = squad.is_moving() and (not is_instance_valid(squad.enemy)) and not on_horse
	if iddle:
		if range_mode:
			var anim = _range_weapon.walk_animation if _is_moving else _range_weapon.ready_animation
			if _current_anim_body != anim:
				_current_anim_body = anim
				body_animation_state.travel(_current_anim_body)
			
		if melee_mode:
			var attack_move = squad.attack_move
			var anim = _melee_weapon.walk_animation if (_is_moving and not attack_move) else _melee_weapon.ready_animation
			if _current_anim_body != anim:
				_current_anim_body = anim
				body_animation_state.travel(_current_anim_body)
		
	if not on_horse:
		var anim = "walk" if _is_moving or (enemy_assign and melee_mode) else "iddle"
		if _current_anim_walk != anim:
			_current_anim_walk = anim
			leg_animation_state.travel(_current_anim_walk)
			

func set_dead():
	.set_dead()
	
	_current_anim_body = "die"
	_current_anim_walk = "die"
	
	body_animation_state.start(_current_anim_body)
	leg_animation_state.start(_current_anim_walk)

func _on_auto_iddle_timer_timeout():
	iddle = true
	enemy = null
	enemy_assign = false
