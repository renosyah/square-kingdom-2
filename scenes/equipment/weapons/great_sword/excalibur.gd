extends MeleeWeapon

func get_attack_damage(enemy_squad_attribute :Array) -> int:
	var dmg = attack_damage
	
	if enemy_squad_attribute[1] == 2: # using two handed
		dmg += attack_damage * bonus_damage
		
	if enemy_squad_attribute[0] == 0: # is infantry
		dmg += attack_damage * bonus_damage
	
	return dmg
