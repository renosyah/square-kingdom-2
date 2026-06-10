extends MeleeWeapon

func get_attack_damage(enemy_squad_attribute :Array) -> int:
	var dmg = attack_damage
	
	if enemy_squad_attribute[0] in [1,2]: # is cavalry or siege
		dmg += attack_damage * bonus_damage
	
	if enemy_squad_attribute[3] in [0,1,2]: # no or light armor or medium
		dmg += attack_damage * bonus_damage
		
	if enemy_squad_attribute[4]: # have shield
		dmg += attack_damage * bonus_damage
	
	return dmg
