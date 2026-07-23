extends MeleeWeapon

func get_attack_damage(target, _enemy_squad_attribute :Array) -> int:
	return target.max_hp * 0.50
