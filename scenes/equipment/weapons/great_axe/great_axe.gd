extends MeleeWeapon

func get_attack_damage(target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[4] or enemy_squad_attribute[0] == 1: # have shield or cav
		return attack_damage + int(attack_damage * bonus_damage)
	return attack_damage
