extends MeleeWeapon

func get_attack_damage(enemy_squad_attribute :Array) -> int:
	var dmg = attack_damage
	
	if enemy_squad_attribute[0] == 1: # is cavalry
		dmg += attack_damage * bonus_damage

	return dmg
