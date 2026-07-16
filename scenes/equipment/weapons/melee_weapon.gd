extends Equipment
class_name MeleeWeapon

const sword_sounds = [
	preload("res://assets/sounds/weapons/sword_1.wav"),
	preload("res://assets/sounds/weapons/sword_2.wav"),
	preload("res://assets/sounds/weapons/sword_3.wav"),
	preload("res://assets/sounds/weapons/sword_4.wav"),
	preload("res://assets/sounds/weapons/sword_5.wav"),
	preload("res://assets/sounds/weapons/sword_6.wav")
]

export var attack_damage :int
export var bonus_damage :float = 0.15
export var show_on_stored :bool = true

export var walk_animation :String = "walk"
export var ready_animation :String = "weapon_ready"
export var attack_animation :String

export var attack_animations :Array
export var has_splash_damage :bool = false

func _ready():
	if attack_animations.empty():
		attack_animations = [attack_animation]
		
func get_sound() -> AudioStream:
	return sword_sounds.pick_random()
	
func get_attack_damage(target, enemy_squad_attribute :Array) -> int:
	return attack_damage
