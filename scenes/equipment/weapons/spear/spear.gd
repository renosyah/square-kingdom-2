extends MeleeWeapon

func get_attack_damage(_target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[0] == 1 or enemy_squad_attribute[1] == 2: # is cavalry or using two handed
		return attack_damage + int(attack_damage * bonus_damage)
		
	return attack_damage
