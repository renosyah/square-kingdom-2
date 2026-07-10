extends MeleeWeapon

func get_attack_damage(_target, enemy_squad_attribute :Array) -> int:
	if enemy_squad_attribute[0] == 0: # is infantry
		var dmg :int = attack_damage + int(attack_damage * bonus_damage)
		return dmg * 2
	return attack_damage

