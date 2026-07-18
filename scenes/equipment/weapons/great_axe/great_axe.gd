extends MeleeWeapon

func get_attack_damage(target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[0] == 1: # cav
		return attack_damage + int(attack_damage * bonus_damage)
		
	if enemy_squad_attribute[4]: # have shield get double
		var dmg :int = attack_damage + int(attack_damage * bonus_damage)
		return dmg * 2
		
	return attack_damage
