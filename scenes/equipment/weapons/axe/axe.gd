extends MeleeWeapon

func get_attack_damage(_target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[4] and enemy_squad_attribute[0] == 0: # infantry have shield
		return attack_damage + int(attack_damage * bonus_damage)
	return attack_damage
