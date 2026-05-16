extends SquadMember

onready var leg_animation_state = $leg_animation_tree.get("parameters/playback")
onready var body_animation_state = $body_animation_tree.get("parameters/playback")
onready var tween = $Tween

onready var range_weapon_holder = $pivot/body/hand_r/range_weapon_holder
onready var shield_holder = $pivot/body/hand_l/shield_holder
onready var weapon_holder = $pivot/body/hand_r/weapon_holder

onready var _range_weapon = $pivot/body/hand_r/range_weapon_holder/bow

var _last_pos :Vector3
var range_mode :bool

func melee_attack():
	#.melee_attack()
	
	if is_dead or not iddle:
		return
		
	range_mode = false
	enemy_assign = true
	iddle = false
	
	_last_pos = global_position
	
	weapon_holder.visible = true
	shield_holder.visible = true
	range_weapon_holder.visible = false
	
	look_at(enemy.global_position, Vector3.UP)
	tween.interpolate_property(self, "translation", global_position, enemy.global_position, 0.8)
	tween.start()
	yield(tween,"tween_completed")
	
	body_animation_state.travel("weapon_slash_attack")
	
func _on_melee_attack_performed():
	tween.interpolate_property(self, "translation", global_position, _last_pos, 1.2)
	tween.start()
	yield(tween,"tween_completed")
	
	emit_signal("attack_performed", self, enemy)
	
	iddle = true
	enemy = null
	enemy_assign = false
	
func range_attack():
	#.range_attack()
	
	if is_dead or not iddle:
		return
		
	range_mode = true
	enemy_assign = true
	iddle = false
	
	weapon_holder.visible = false
	shield_holder.visible = false
	range_weapon_holder.visible = true
	
	body_animation_state.travel("shot_range_weapon")
	
func _on_pulling_bow():
	_range_weapon.pull()
	
func _on_release_bow():
	_range_weapon.release()
	
	var arrow = preload("res://scenes/projectiles/arrow.tscn").instance()
	add_child(arrow)
	arrow.translation = global_position
	arrow.to = enemy.global_position + Vector3.ONE * rand_range(-0.5,0.5)
	arrow.launch()
	
	yield(arrow,"on_reach")
	arrow.queue_free()
	
func _on_range_attack_performed():
	emit_signal("attack_performed", self, enemy)
	
	iddle = true
	enemy = null
	enemy_assign = false
	
func moving(delta :float):
	.moving(delta)
	
	if is_dead:
		return
		
	if iddle:
		body_animation_state.travel("walk" if squad.is_moving() else "weapon_ready")
		
	leg_animation_state.travel("walk" if squad.is_moving() or (enemy_assign and not range_mode) else "iddle")

func dead():
	.dead()
	
	visible = false

