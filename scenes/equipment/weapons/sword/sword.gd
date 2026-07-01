extends MeleeWeapon

func get_attack_damage(target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[0] == 0: # is infantry
		return attack_damage + (target.hp * bonus_damage)
		
	return attack_damage
