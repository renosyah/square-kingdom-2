extends Spatial

const buff_color = preload("res://assets/squad_buff_debuff_indicator/buff_color.tres")
const debuff_color = preload("res://assets/squad_buff_debuff_indicator/debuff_color.tres")

export var icon :StreamTexture
export var is_buff :bool

onready var mesh_instance = $MeshInstance
onready var sprite_3d = $Sprite3D

func _ready():
	sprite_3d.texture = icon
	sprite_3d.modulate = Color.green if is_buff else Color.red
	mesh_instance.set_surface_material(0, buff_color if is_buff else debuff_color)
	
func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
