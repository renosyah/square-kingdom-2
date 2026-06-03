extends SiegeEngine

const bolt_projectile_scene = preload("res://scenes/projectiles/balista_bolt.tscn")
const arm_swing_audio = preload("res://assets/sounds/sfx/balista_firing.wav")

onready var animation_state = $AnimationTree.get("parameters/playback")
onready var ammo = $pivot/Spatial/arm/ammo
onready var arm = $pivot/Spatial/arm

func attack():
	.attack()
	
	if not iddle:
		return
	
	iddle = false
	animation_state.travel("shot_bolt")
	
func _on_bolt_shot():
	if not Global.current_root:
		return
		
	_combat_sound.stream = arm_swing_audio
	_combat_sound.play()
	
	var bolt :BaseProjectile = bolt_projectile_scene.instance()
	bolt.connect("on_reach", self ,"_on_projectile_reach", [bolt])
	Global.current_root.add_child(bolt)
	bolt.translation = ammo.global_position
	bolt.to = target_position + Vector3.ONE * rand_range(-0.5,0.5)
	bolt.launch()
	
func _on_projectile_launched():
	iddle = true
	
func _on_projectile_reach(boulder):
	emit_signal("on_set_damage_to_tile", self, tile_target, attack_damage)
	
func moving(delta :float):
	.moving(delta)
	
	#arm.rotation.y = lerp_angle(arm.rotation.y, rotation.y - squad.rotation.y, 25 * delta)
	
	if iddle and squad.visible:
		var _is_moving = squad.is_moving() and (not is_instance_valid(squad.enemy))
		var anim = "walk" if _is_moving else "iddle"
		if _current_anim_walk != anim:
			_current_anim_walk = anim
			animation_state.travel(_current_anim_walk)
