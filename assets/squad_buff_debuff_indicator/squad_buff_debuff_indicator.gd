extends Spatial

const buff_debuff_icon = [
	null,
	preload("res://assets/user_interface/icons/arrow_down.png"), #1
	preload("res://assets/user_interface/icons/angry.png"), #2
	preload("res://assets/user_interface/icons/scare.png"), #3
	preload("res://assets/user_interface/icons/hand_stop.png"),#4
	preload("res://assets/user_interface/icons/attack.png"),#5
	preload("res://assets/user_interface/icons/arrow_up.png"),#6
	preload("res://assets/user_interface/icons/movement_mode.png"),#7
	preload("res://assets/user_interface/icons/defend.png"),#8
	preload("res://assets/user_interface/icons/hp.png"),#9
	preload("res://assets/user_interface/icons/fist_up.png")#10
	
]

const buff_color = preload("res://assets/squad_buff_debuff_indicator/buff_color.tres")
const debuff_color = preload("res://assets/squad_buff_debuff_indicator/debuff_color.tres")

export var icon_idx :int
export var is_buff :bool
var squad :BaseSquad

onready var mesh_instance = $MeshInstance
onready var sprite_3d = $Sprite3D

func _ready():
	sprite_3d.texture = buff_debuff_icon[icon_idx]
	sprite_3d.modulate = Color.green if is_buff else Color.red
	mesh_instance.set_surface_material(0, buff_color if is_buff else debuff_color)
	
func _process(delta):
	if is_instance_valid(squad):
		translation = squad.get_current_tile_v3()
	
func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
