extends MeleeWeapon

func get_attack_damage(enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[0] == 1: # is cavalry
		return attack_damage
		
	var dmg = attack_damage
	if enemy_squad_attribute[3] in [2,3]: # medium or heavy armor
		dmg += attack_damage * bonus_damage

	return dmg
