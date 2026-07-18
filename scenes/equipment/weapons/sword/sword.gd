extends MeleeWeapon

func get_attack_damage(_target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[0] == 0: # is infantry
		var dmg :int = attack_damage + int(attack_damage * bonus_damage)
		
		if enemy_squad_attribute[1] == 1: # and also using spear
			dmg = dmg + int(attack_damage * bonus_damage)
			
		return dmg
		
	return attack_damage
