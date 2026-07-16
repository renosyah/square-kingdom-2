extends SiegeEngine

const boulder_projectile_scene = preload("res://scenes/projectiles/boulder.tscn")
const arm_swing_audio = preload("res://assets/sounds/unit/swing/swing.wav")

onready var animation_state = $AnimationTree.get("parameters/playback")
onready var ammo = $pivot/arm/ammo

func attack():
	.attack()
	
	if not iddle:
		return
	
	iddle = false
	animation_state.travel("lob_boulder")
	
func _on_boulder_lob():
	if not Global.current_root:
		return
		
	_combat_sound.stream = arm_swing_audio
	_combat_sound.play()
	
	var boulder :BaseProjectile = boulder_projectile_scene.instance()
	boulder.connect("on_reach", self ,"_on_projectile_reach", [boulder])
	Global.current_root.add_child(boulder)
	boulder.translation = ammo.global_position
	boulder.to = target_position + Vector3.ONE * rand_range(-0.5,0.5)
	boulder.launch()
	
func _on_projectile_launched():
	iddle = true
	
func _on_projectile_reach(boulder):
	emit_signal("on_set_damage_to_tile", self, tile_target, attack_damage)
	
func moving(delta :float):
	.moving(delta)
	
	if not squad:
		return
	
	if iddle and squad.visible:
		var _is_moving = squad.is_moving() and (not is_instance_valid(squad.enemy))
		var anim = "walk" if _is_moving else "iddle"
		if _current_anim_walk != anim:
			_current_anim_walk = anim
			animation_state.travel(_current_anim_walk)
