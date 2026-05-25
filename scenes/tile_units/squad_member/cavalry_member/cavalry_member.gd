extends SquadMember
class_name CavalryMember

const rider_scene = preload("res://scenes/tile_units/squad_member/infantry_member/infantry_member.tscn")

export var horse_skin :SpatialMaterial

var _rider

onready var meshes = [
	$pivot/body/body,
	$pivot/body/leg_f_l/leg,
	$pivot/body/leg_f_r/leg,
	$pivot/body/leg_b_l/leg,
	$pivot/body/leg_b_r/leg
]


onready var animation_state = $AnimationTree.get("parameters/playback")
onready var rider_holder = $rider_holder

func _ready():
	_rider = rider_scene.instance()
	_rider.squad = squad
	_rider.name = "%s_rider" % name
	
	_rider.headgear = headgear
	_rider.armor = armor
	_rider.shield = shield
	_rider.melee_weapon = melee_weapon
	_rider.range_weapon = range_weapon
	_rider.material = material
	_rider.on_horse = true
	
	_rider.hp = hp
	_rider.max_hp = max_hp
	
	_rider.connect("on_set_damage_to_tile", squad, "_on_member_set_damage_to_tile")
	_rider.connect("on_set_damage_to_target", squad, "_on_member_set_damage_to_target")
	
	rider_holder.add_child(_rider)
	
	_rider.set_as_toplevel(true)
	_rider.translation = rider_holder.global_position
	
	for i in meshes:
		var m :MeshInstance = i
		m.set_surface_material(0, horse_skin)
	
func prepare_melee_weapon():
	.prepare_melee_weapon()
	
	_rider.prepare_melee_weapon()
	
func prepare_range_weapon():
	.prepare_range_weapon()
	
	_rider.prepare_range_weapon()
	
func melee_attack():
	.melee_attack()
	
	_rider.enemy = enemy
	_rider.melee_attack()
	iddle = _rider.iddle
	
func range_attack():
	.range_attack()
	
	_rider.enemy = enemy
	_rider.range_attack()
	iddle = _rider.iddle
	
func dead():
	.dead()
	
	_rider.dead()
	animation_state.travel("dead")
	
func resurect():
	.resurect()
	
	_rider.resurect()
	animation_state.start("iddle")
	
func moving(delta :float):
	#.moving(delta)
	
	_rider.translation = rider_holder.global_position
	iddle = _rider.iddle
	
	if is_dead:
		return
		
	rotation.y = lerp_angle(rotation.y, squad.rotation.y, 5 * delta)
	
	#var run_anim = "run" if not squad.attack_move else "walk"
	animation_state.travel("walk" if squad.is_moving() else "iddle")




















