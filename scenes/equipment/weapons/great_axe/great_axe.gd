extends MeleeWeapon

func get_attack_damage(target, enemy_squad_attribute :Array) -> int:
	# have shield or cav
	if enemy_squad_attribute[4] or enemy_squad_attribute[0] == 1:
		return attack_damage + (target.hp * bonus_damage)
	
	return attack_damage
