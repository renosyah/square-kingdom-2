extends MeleeWeapon

func get_attack_damage(_target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[0] == 1: # is cavalry
		return attack_damage
		
	if enemy_squad_attribute[1] == 2 or enemy_squad_attribute[4]: # using two handed or have shield
		return attack_damage + int(attack_damage * bonus_damage)
		
	return attack_damage
