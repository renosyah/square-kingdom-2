extends MeleeWeapon

func get_attack_damage(target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[0] == 1: # is cavalry
		return attack_damage
		
	if enemy_squad_attribute[3] in [2,3]: # medium or heavy armor
		return attack_damage + (target.hp * bonus_damage)
		
	return attack_damage
