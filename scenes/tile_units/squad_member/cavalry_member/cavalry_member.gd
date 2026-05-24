extends SquadMember

const rider_scene = preload("res://scenes/tile_units/squad_member/infantry_member/infantry_member.tscn")

var rider

onready var animation_state = $AnimationTree.get("parameters/playback")
onready var rider_holder = $rider_holder

func _ready():
	rider = rider_scene.instance()
	rider.squad = squad
	rider.name = "%s_rider" % name
	
	rider.headgear = headgear
	rider.armor = armor
	rider.shield = shield
	rider.melee_weapon = melee_weapon
	rider.range_weapon = range_weapon
	rider.material = material
	rider.on_horse = true
	
	rider.hp = hp
	rider.max_hp = max_hp
	
	rider.connect("on_set_damage_to_tile", squad, "_on_member_set_damage_to_tile")
	rider.connect("on_set_damage_to_target", squad, "_on_member_set_damage_to_target")
	
	rider_holder.add_child(rider)
	
	rider.set_as_toplevel(true)
	rider.translation = rider_holder.global_position
	
func prepare_melee_weapon():
	.prepare_melee_weapon()
	
	rider.prepare_melee_weapon()
	
func prepare_range_weapon():
	.prepare_range_weapon()
	
	rider.prepare_range_weapon()
	
func melee_attack():
	.melee_attack()
	
	rider.enemy = enemy
	rider.melee_attack()
	iddle = rider.iddle
	
func range_attack():
	.range_attack()
	
	rider.enemy = enemy
	rider.range_attack()
	iddle = rider.iddle
	
func dead():
	.dead()
	
	rider.dead()
	animation_state.travel("dead")
	
func resurect():
	.resurect()
	
	rider.resurect()
	animation_state.start("iddle")
	
func moving(delta :float):
	#.moving(delta)
	
	rider.translation = rider_holder.global_position
	iddle = rider.iddle
	
	if is_dead:
		return
		
	rotation.y = lerp_angle(rotation.y, squad.rotation.y, 5 * delta)
	animation_state.travel("walk" if squad.is_moving() else "iddle")
