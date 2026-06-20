extends Node
class_name AbilityHandle

const squad_abilities = [
	null,
	{
		# melee pike weapon 1
		"name": "Hold'em",
		"icon": preload("res://assets/user_interface/ability/pike_up_ability.png"),
		"detail": "Hold the line! Stop enemies in their tracks and reduce their movement speed by 50% for 15 seconds.",
		"type": "melee",
		"weapon_idx": 4,
		"cooldown" : 15.0,
		"required_enemy": true,
	},
	{
		# melee great sword weapon 2
		"name": "Fear!",
		"icon": preload("res://assets/user_interface/ability/intimidation_ability.png"),
		"detail": "Strike fear into the enemy, reducing all attack speeds by 50% for 15 seconds.",
		"type": "melee",
		"weapon_idx": 10,
		"cooldown" : 30.0,
		"required_enemy": true,
	},
	{
		# melee axe weapon 3
		"name": "Beserk!",
		"icon": preload("res://assets/user_interface/ability/beserk_ability.png"),
		"detail": "Unleash a furious assault, increasing melee attack speed by 50%, move speed by 25% but receive 25% damage for 15 seconds.",
		"type": "melee",
		"weapon_idx": 7,
		"cooldown" : 35.0,
		"required_enemy": false,
	},
	{
		# range longbow weapon 4
		"name": "Rain Arrows!",
		"icon": preload("res://assets/user_interface/ability/rain_arrow_ability.png"),
		"detail": "Cover the battlefield with arrows, increasing ranged attack speed by 50% while slowing affected enemies by 50% for 15 seconds.",
		"type": "range",
		"weapon_idx": 4,
		"cooldown" : 30.0,
		"required_enemy": true,
	},
	{
		# range javeline weapon 5
		"name": "Chase!",
		"icon": preload("res://assets/user_interface/ability/chase_ability.png"),
		"detail": "Don't let them escape! Increase movement speed by 50% for 10 seconds.",
		"type": "range",
		"weapon_idx": 1,
		"cooldown" : 25.0,
		"required_enemy": false,
	},
	{
		# melee great axe weapon 6
		"name": "Scare!",
		"icon": preload("res://assets/user_interface/ability/scare_ability.png"),
		"detail": "Break the enemy's courage, forcing them to flee from battle.",
		"type": "melee",
		"weapon_idx": 9,
		"cooldown" : 45.0,
		"required_enemy": true,
	},
	{
		# range crossbow weapon 7
		"name": "Pin'em!",
		"icon": preload("res://assets/user_interface/ability/pinned_ability.png"),
		"detail": "Pin the enemy down, reducing their movement speed by 80% for 15 seconds.",
		"type": "range",
		"weapon_idx": 5,
		"cooldown" : 65.0,
		"required_enemy": true,
	},
	{
		# all shield 8
		"name": "Shield Up!",
		"icon": preload("res://assets/user_interface/ability/shield_ability.png"),
		"detail": "Raise your shields! Reduce incoming damage by 50%, but decrease attack speed by 50% and movement speed by 70% for 25 seconds.",
		"type": "shield",
		"weapon_idx": 0, # <- ignore this
		"cooldown" : 30.0,
		"required_enemy": false,
	},
	{
		# range bow weapon 9
		"name": "Suppress!",
		"icon": preload("res://assets/user_interface/ability/suppress_ability.png"),
		"detail": "Keep enemy archers under pressure, reducing their ranged attack speed by 50% for 10 seconds.",
		"type": "range",
		"weapon_idx": 3,
		"cooldown" : 50.0,
		"required_enemy": true,
	},
	{
		# melee pitchfork weapon 10
		"name": "Riot!",
		"icon": preload("res://assets/user_interface/ability/riot_ability.png"),
		"detail": "In the absolute chaos and confusion, Temporary weaken enemy defence by 25% and slow them down by 50% for 15 second",
		"type": "melee",
		"weapon_idx": 1,
		"cooldown" : 60.0,
		"required_enemy": true,
	},
	{
		# range longbow weapon 11
		"name": "Heavy Draw",
		"icon": preload("res://assets/user_interface/ability/heavy_draw_ability.png"),
		"detail": "Pull your bow as hardest as you can, increase range damage by 50% but range attack 50% slower for 15 second",
		"type": "range",
		"weapon_idx": 4,
		"cooldown" : 30.0,
		"required_enemy": false,
	},
	{
		# range crossbow weapon 12
		"name": "Bodkin Point",
		"icon": preload("res://assets/user_interface/ability/bodkin_point_ability.png"),
		"detail": "This tip can punch through even their moral, gain 50% more damage for 10 second",
		"type": "range",
		"weapon_idx": 5,
		"cooldown" : 25.0,
		"required_enemy": false,
	},
	{
		# range javeline  weapon 13
		"name": "Yeet!",
		"icon": preload("res://assets/user_interface/ability/heavy_javeline_ability.png"),
		"detail": "Throw thing as hard you can, 50% deal more damage with range attack 50% slower for 10 second",
		"type": "range",
		"weapon_idx": 1,
		"cooldown" : 25.0,
		"required_enemy": false,
	},
	{
		# melee great sword 14
		"name": "Death Blow!",
		"icon": preload("res://assets/user_interface/ability/death_blow_ability.png"),
		"detail": "Remember your training, deal 50% more damage at cost of 50% slower attack for 15 second",
		"type": "melee",
		"weapon_idx": 10,
		"cooldown" : 35.0,
		"required_enemy": false,
	},
	{
		# melee great axe 15
		"name": "Cleave!",
		"icon": preload("res://assets/user_interface/ability/cleave_ability.png"),
		"detail": "This axes can cut tree and man behind it, deal 50% damage with 50% slow attack for 15 second",
		"type": "melee",
		"weapon_idx": 9,
		"cooldown" : 35.0,
		"required_enemy": false,
	},
	{
		# melee pitchfork weapon 16
		"name": "Offering!",
		"icon": preload("res://assets/user_interface/ability/give_food_ability.png"),
		"detail": "Carry food, water, and supplies to nearby allies, restoring some of their health even while in combat.",
		"type": "melee",
		"weapon_idx": 1,
		"cooldown" : 15.0,
		"required_enemy": false,
	},
	{
		# melee pitchfork weapon 17
		"name": "On Me!",
		"icon": preload("res://assets/user_interface/ability/rally_ability.png"),
		"detail": "Lead by example and rally nearby allies, granting +25% attack speed, +15% movement speed, and +15% damage for 25 seconds.",
		"type": "hero",
		"weapon_idx": 0, # <- ignore
		"cooldown" : 80.0,
		"required_enemy": false,
	},
]

const buff_debuff_icons = [
	null,
	preload("res://assets/user_interface/icons/modifier_effect/buffed.png"),#1
	preload("res://assets/user_interface/icons/modifier_effect/debuffed.png"), #2
	preload("res://assets/user_interface/icons/modifier_effect/beserk.png"), #3
	preload("res://assets/user_interface/icons/modifier_effect/scare.png"), #4
	preload("res://assets/user_interface/icons/modifier_effect/heal.png"),#5
	preload("res://assets/user_interface/icons/modifier_effect/fist_up.png"),#6
	preload("res://assets/user_interface/icons/modifier_effect/move_speed.png"),#7
	preload("res://assets/user_interface/icons/modifier_effect/defence_down.png"),#8
	preload("res://assets/user_interface/icons/modifier_effect/defence_up.png")#9
]

const icon_null = 0
const icon_buffed = 1
const icon_debuffed = 2
const icon_beserk = 3
const icon_scared = 4
const icon_heal = 5
const icon_fist_up = 6
const icon_move_speed = 7
const icon_defence_down = 8
const icon_defence_up = 9

static func use_squad_ability(squad :BaseSquad, position_manager :TilePositionManager):
	var squad_ability_idx :int = squad.squad_ability_idx
	if squad_ability_idx == 0:
		return
		
	# ability still on cooldown
	if squad.get_ability_cooldown()[0]:
		return
		
	match squad_ability_idx:
		1: # stop enemy and -50% speed for them
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				if squad.is_in_melee_range(enemy):
					var icon_hand_stop = 4
					enemy.set_modifiers([[squad.modifier_move_speed, -0.50, 15, icon_hand_stop]])
					enemy.stop()
				
		2: # enemy -50% attack speed for 25 sec
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				if squad.is_in_melee_range(enemy):
					enemy.set_modifiers([
						[squad.modifier_melee_speed, -0.50, 25, icon_null], # melee attack speed
						[squad.modifier_range_speed, -0.50, 25, icon_scared] # range attack speed 
					])
				
		3: # +50% melee attack speed and +20% movement speed, -25% damage resistance for 15 sec
			var icon_angry = 2
			squad.set_modifiers([
				[squad.modifier_melee_speed, 0.50, 15, icon_angry], # melee attack speed
				[squad.modifier_move_speed, 0.20, 25, icon_null], # movement speed
				[squad.modifier_damage_receive, 0.25, 25, icon_null], # damage receive
			])
			
		4:# +50% range attack speed for 15 sec
			squad.set_modifiers([[squad.modifier_range_speed, 0.50, 15, icon_buffed]]) # range attack speed 
			
			# -50% speed for enemy
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				enemy.set_modifiers([[squad.modifier_move_speed, -0.50, 15, icon_debuffed]]) # movement speed
				
		5:# +50% speed for 10 sec
			squad.set_modifiers([[squad.modifier_move_speed, 0.50, 10, icon_move_speed]]) # movement speed
			
		6: # set enemy flee
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				if squad.is_in_melee_range(enemy):
					enemy.set_modifiers([[squad.modifier_move_speed, -0.50, 15, icon_scared]]) # movement speed
					enemy.retreat()
					
		7: # -80% move speed for 15 sec
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				enemy.set_modifiers([[squad.modifier_move_speed, -0.80, 15, icon_debuffed]]) # movement speed
				
		8: # -50% damage receive, -50% attack speed, -75% move speed, for 25 sec
			squad.set_modifiers([
				[squad.modifier_damage_receive, -0.50, 25, icon_defence_up], # damage receive
				[squad.modifier_melee_speed, -0.50, 25, icon_null], # melee attack speed
				[squad.modifier_range_speed, -0.50, 25, icon_null], # range attack speed 
				[squad.modifier_move_speed, -0.25, 25, icon_null], # movement speed
			])
			
		9: # -50% range attack speed for enemy
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				enemy.set_modifiers([[squad.modifier_range_speed, -0.50, 10, icon_debuffed]]) # range attack speed
				
		10: # -25% damage resistance & 50% slower
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				enemy.set_modifiers([
					[squad.modifier_move_speed, -0.50, 15, icon_null], # movement speed
					[squad.modifier_damage_receive, 0.25, 15, icon_defence_down], # damage receive
				])
				
		11,12,13: # 50% range damage, 50% slowest rate of fire
			squad.set_modifiers([
				[squad.modifier_range_damage, 0.50, 15, icon_buffed], # damage deal
				[squad.modifier_range_speed, -0.50, 15, icon_null], #  attack speed 
			])
			
		14,15: # 50% melee damage, 50% slowest rate of fire
			squad.set_modifiers([
				[squad.modifier_melee_damage, 0.50, 15, icon_buffed], # damage deal
				[squad.modifier_melee_speed, -0.50, 15, icon_null], # attack speed 
			])
			
		16, 17: # get nearby squads
			var ranges :Array = TileMapUtils.get_adjacent_tiles(TileMapUtils.ARROW_DIRECTIONS, squad.current_tile, 1) + [squad.current_tile]
			var squads :Array = _get_squad_in_range(position_manager.get_positions(), ranges)
			for i in squads:
				var s :BaseSquad = i
				if s != squad and s.team == squad.team:
					if squad_ability_idx == 16: # heal
						s.set_modifiers([ [squad.modifier_move_speed, 0.10, 2, icon_heal]]) # just for indicator
						s.healing()
						
					elif squad_ability_idx == 17: # 25% attack speed, 15% speed and 15% attack damage for 10
						s.set_modifiers([
							[squad.modifier_melee_speed, 0.25, 25, icon_fist_up], 
							[squad.modifier_range_speed, 0.25, 25, icon_null],
							[squad.modifier_move_speed, 0.15, 25, icon_null],
							[squad.modifier_melee_damage, 0.15, 25, icon_null],
							[squad.modifier_range_damage, 0.15, 25, icon_null],
						])
					
	squad.start_ability_cooldown(squad_abilities[squad_ability_idx]["cooldown"])

static func _get_squad_in_range(unit_position :Dictionary, ranges :Array) -> Array:
	var squads = []
	for pos in ranges:
		if not unit_position.has(pos):
			continue
			
		var unit_positions :Array = unit_position[pos]
		if unit_positions.empty():
			continue
			
		for unit in unit_positions:
			if is_instance_valid(unit):
				if not unit.is_dead:
					squads.append(unit)
			
	return squads












