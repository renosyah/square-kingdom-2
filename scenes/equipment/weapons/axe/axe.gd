extends MeleeWeapon

func get_attack_damage(enemy_squad_attribute :Array) -> int:
	var dmg = attack_damage
	
	if enemy_squad_attribute[1] == 2: # using two handed
		dmg += attack_damage * bonus_damage
	
	if enemy_squad_attribute[3] in [0,1]: # no or light armor
		dmg += attack_damage * bonus_damage
		
	if enemy_squad_attribute[4]: # have shield
		dmg += attack_damage * bonus_damage
	
	return dmg
