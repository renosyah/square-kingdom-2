extends Equipment
class_name MeleeWeapon

export var attack_damage :int
export var show_on_stored :bool = true
export var counters :Array = [] # role squad id
export var bonus_damage :int = 6 # times of damage bonus

export var walk_animation :String = "walk"
export var ready_animation :String = "weapon_ready"
export var attack_animation :String

export var attack_animations :Array

func _ready():
	if attack_animations.empty():
		attack_animations = [attack_animation]

func get_attack_damage(enemy_squad_role :int) -> int:
	if enemy_squad_role in counters:
		return attack_damage * bonus_damage
		
	return attack_damage
