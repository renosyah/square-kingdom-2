extends Spatial

export var color :Color
onready var sprite_3d = $Sprite3D

func _ready():
	sprite_3d.modulate = color

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
