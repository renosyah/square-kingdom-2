extends Equipment
class_name MeleeWeapon

export var attack_damage :int
export var show_on_stored :bool = true
export var bonus_damage :int = 6 # times of damage bonus

export var walk_animation :String = "walk"
export var ready_animation :String = "weapon_ready"
export var attack_animation :String

export var attack_animations :Array
export var has_splash_damage :bool = false

func _ready():
	if attack_animations.empty():
		attack_animations = [attack_animation]

func get_attack_damage(enemy_squad_attribute :Array) -> int:
	return attack_damage
