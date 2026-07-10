extends Node
class_name AbilityHandle

const squad_abilities = [
	null,
	{
		# melee pike weapon 1
		# affect : melee enemy (on hit)
		"name": "Hold'em",
		"icon": preload("res://assets/user_interface/ability/pike_up_ability.png"),
		"detail": "Hold the line! Stop enemies in their tracks and reduce their movement speed by -50% for 15 seconds.",
		"type": "melee",
		"weapon_idx": 4,
		"cooldown" : 15.0,
		"required_enemy": false,
	},
	{
		# melee great sword weapon 2
		# affect : melee enemy (instant)
		"name": "Fear!",
		"icon": preload("res://assets/user_interface/ability/intimidation_ability.png"),
		"detail": "Strike fear into the enemy, reducing all attack speeds by -50% for 15 seconds.",
		"type": "melee",
		"weapon_idx": 10,
		"cooldown" : 30.0,
		"required_enemy": true,
	},
	{
		# melee axe weapon 3
		# affect : melee self (instant)
		"name": "Beserk!",
		"icon": preload("res://assets/user_interface/ability/beserk_ability.png"),
		"detail": "Unleash a furious assault, increasing melee attack speed by +50% and movement speed by +25%, but suffer -25% more incoming damage for 15 seconds.",
		"type": "melee",
		"weapon_idx": 7,
		"cooldown" : 35.0,
		"required_enemy": false,
	},
	{
		# range longbow weapon 4
		# affect : range self (instant)
		# affect : range enemy (on hit)
		"name": "Rain Arrows!",
		"icon": preload("res://assets/user_interface/ability/rain_arrow_ability.png"),
		"detail": "Cover the battlefield with arrows, increasing ranged attack speed by +50% while slowing affected enemies by -15% for 15 seconds.",
		"type": "range",
		"weapon_idx": 4,
		"cooldown" : 40.0,
		"required_enemy": true,
	},
	{
		# range javeline weapon 5
		# affect : range self (instant)
		"name": "Chase!",
		"icon": preload("res://assets/user_interface/ability/chase_ability.png"),
		"detail": "Don't let them escape! Increase movement speed by +50% for 10 seconds.",
		"type": "range",
		"weapon_idx": 1,
		"cooldown" : 25.0,
		"required_enemy": false,
	},
	{
		# melee great axe weapon 6
		# affect : melee self (instant)
		# affect : area (instant)
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
		# affect : range self (instant)
		# affect : range enemy (on hit)
		"name": "Pin'em!",
		"icon": preload("res://assets/user_interface/ability/pinned_ability.png"),
		"detail": "Pin the enemy down, cripple reducing their movement speed by -80% for 15 seconds.",
		"type": "range",
		"weapon_idx": 5,
		"cooldown" : 65.0,
		"required_enemy": true,
	},
	{
		# all shield 8
		# affect : self (instant)
		"name": "Shield Up!",
		"icon": preload("res://assets/user_interface/ability/shield_ability.png"),
		"detail": "Raise your shields! Gain +50% damage resistance, but decrease attack speed by -50% and movement speed by -70% for 25 seconds.",
		"type": "shield",
		"weapon_idx": 0, # <- ignore this
		"cooldown" : 30.0,
		"required_enemy": false,
	},
	{
		# range bow weapon 9
		# affect : range self (instant)
		# affect : range enemy (on hit)
		"name": "Suppress!",
		"icon": preload("res://assets/user_interface/ability/suppress_ability.png"),
		"detail": "Keep enemy archers under pressure, reducing their ranged attack speed by -50% but doing -25% less damage for 10 seconds.",
		"type": "range",
		"weapon_idx": 3,
		"cooldown" : 25.0,
		"required_enemy": true,
	},
	{
		# melee pitchfork weapon 10
		# affect : melee enemy (instant)
		"name": "Riot!",
		"icon": preload("res://assets/user_interface/ability/riot_ability.png"),
		"detail": "Overwhelm the enemy with chaos and confusion, reducing their defense by -25% and movement speed by -50% for 15 seconds.",
		"type": "melee",
		"weapon_idx": 1,
		"cooldown" : 60.0,
		"required_enemy": true,
	},
	{
		# range longbow weapon 11
		# affect : range self (instant)
		# affect : melee ally (instant)
		"name": "Heavy Draw",
		"icon": preload("res://assets/user_interface/ability/heavy_draw_ability.png"),
		"detail": "Draw with maximum force, increasing ranged damage by +40% but reducing ranged attack speed by -50% for 15 seconds. Inspire by this, neaby friendly range unit also receive +10% range damage",
		"type": "range",
		"weapon_idx": 4,
		"cooldown" : 30.0,
		"required_enemy": false,
	},
	{
		# range crossbow weapon 12
		# affect : range self (instant)
		# affect : range enemy (on hit)
		"name": "AP Bolts",
		"icon": preload("res://assets/user_interface/ability/bodkin_point_ability.png"),
		"detail": "Fit your bolt with Armor Piercing Custom Bodkin (APCB) bolts for maximum penetration. Increase ranged damage by +40% & inflict bleeding damage each second for 10 seconds.",
		"type": "range",
		"weapon_idx": 5,
		"cooldown" : 45.0,
		"required_enemy": false,
	},
	{
		# range javeline  weapon 13
		# affect : range self (instant)
		"name": "Yeet!",
		"icon": preload("res://assets/user_interface/ability/heavy_javeline_ability.png"),
		"detail": "Stop aiming and start throwing. Javelins deal -25% less damage, but this squad hurls them +50% faster for 10 seconds.",
		"type": "range",
		"weapon_idx": 1,
		"cooldown" : 25.0,
		"required_enemy": false,
	},
	{
		# melee great sword 14
		# affect : melee self (instant)
		# affect : melee enemy (on hit)
		"name": "Death Blow!",
		"icon": preload("res://assets/user_interface/ability/death_blow_ability.png"),
		"detail": "Abandon haste and commit to a killing strike. Remove all speed modifiers affecting this squad, then gain +25% melee damage but attack -15% slower for 15 seconds. inflict bleeding damage each second for 10 second",
		"type": "melee",
		"weapon_idx": 10,
		"cooldown" : 35.0,
		"required_enemy": false,
	},
	{
		# melee great axe 15
		# affect : melee self (instant)
		# affect : area (instant)
		"name": "Cleave!",
		"icon": preload("res://assets/user_interface/ability/cleave_ability.png"),
		"detail": "Swing with overwhelming force, +50% melee damage, -50% melee attack speed & All squads in the target tile suffer -25% damage resistance for 15 seconds",
		"type": "melee",
		"weapon_idx": 9,
		"cooldown" : 35.0,
		"required_enemy": false,
	},
	{
		# melee pitchfork weapon 16
		# affect : melee ally (instant)
		"name": "Offering!",
		"icon": preload("res://assets/user_interface/ability/give_food_ability.png"),
		"detail": "Carry food, water, and supplies to nearby allies, restoring +15% of their health even while in combat.",
		"type": "melee",
		"weapon_idx": 1,
		"cooldown" : 15.0,
		"required_enemy": false,
	},
	{
		# special for hero only 17
		# affect : melee ally (instant)
		"name": "On Me!",
		"icon": preload("res://assets/user_interface/ability/rally_ability.png"),
		"detail": "Lead by example and rally nearby allies, granting +25% attack speed, +15% movement speed, and +15% damage for 25 seconds.",
		"type": "hero",
		"weapon_idx": 0, # <- ignore
		"cooldown" : 80.0,
		"required_enemy": false,
	},
	{
		# special for commander only 18
		# affect : melee ally (instant)
		"name": "Regroup!",
		"icon": preload("res://assets/user_interface/ability/regroup_ability.png"),
		"detail": "(Commander Default Ability) Automatically equipped if no other ability is selected. Restore discipline and order, removing all active buffs and debuffs from nearby allies.",
		"type": "commander",
		"weapon_idx": 0, # <- ignore
		"cooldown" : 70.0,
		"required_enemy": false,
	},
	{
		# melee mace weapon 19
		# affect : melee self (instant)
		# affect : melee enemy (on hit)
		"name": "Bonk!",
		"icon": preload("res://assets/user_interface/ability/bonk.png"),
		"detail": "Delivers blow to the enemy head. reducing their damage resistance and melee attack speed by -15%, while your melee attack speed increase by +15% for 10 seconds.",
		"type": "melee",
		"weapon_idx": 13, 
		"cooldown" : 35.0,
		"required_enemy": true,
	},
	{
		# melee warhammer weapon 20
		# affect : melee self (instant)
		# affect : area (instant)
		"name": "Pound!",
		"icon": preload("res://assets/user_interface/ability/pound.png"),
		"detail": "Smash the ground with tremendous force, shaking both earth and enemy. All squads in the target area suffer -20% melee attack speed, -20% damage resistance, and -30% movement speed for 15 seconds.",
		"type": "melee",
		"weapon_idx": 14, 
		"cooldown" : 45.0,
		"required_enemy": true,
	},
	{
		# melee warhammer weapon 21
		# affect : melee self (instant)
		# affect : melee ally (instant)
		"name": "Inspiring!",
		"icon": preload("res://assets/user_interface/ability/bone_breaker.png"),
		"detail": "Display unmatched strength and courage, inspiring nearby warriors to fight harder. Gain +30% melee attack speed, while nearby allies gain +10% attack speed for 15 seconds.",
		"type": "melee",
		"weapon_idx": 14, 
		"cooldown" : 35.0,
		"required_enemy": false,
	},
	{
		# all shield 22
		# affect : melee enemy (instant)
		# affect : range enemy (instant)
		"name": "Taunt!",
		"icon": preload("res://assets/user_interface/ability/taunting.png"),
		"detail": "Bash your shields and hurl insults, forcing the enemy to focus on you. The target’s active ability cooldown is reset back to full, as if it had just been used.",
		"type": "shield",
		"weapon_idx": 0, # <- ignore this
		"cooldown" : 35.0,
		"required_enemy": true,
	},
	{
		# just info
		"name": "Drive By!",
		"icon": preload("res://assets/user_interface/ability/fight_and_ride_ability.png"),
		"detail": "(Cavalry Feature) This is my horse, my horse is amazing. Mounted units can attack and fire ranged weapons without stopping. Enable Attack Move mode to make full use of their mobility and hit-and-run tactics.",
		"type": "cavalry",
		"weapon_idx": 0, # <- ignore this
		"cooldown" : -1.0,
		"required_enemy": false,
	},
	{
		# melee axe weapon 24
		# affect : melee enemy (instant)
		"name": "Shield Breaker!",
		"icon": preload("res://assets/user_interface/ability/shield_breaker_ability.png"),
		"detail": "Use your axe to carve through enemy's shield, make them vulnerable by -60% for 15 seconds.",
		"type": "melee",
		"weapon_idx": 7,
		"cooldown" : 35.0,
		"required_enemy": true,
	},
	{
		# melee excalibur weapon 25
		# affect : melee ally (instant)
		"name": "Encore!",
		"icon":  preload("res://assets/user_interface/ability/encore_ability.png"),
		"detail": "Instantly refresh the ability cooldown of every nearby squad, friend or foe. Heroes are unaffected.",
		"type": "melee",
		"weapon_idx": 15,
		"cooldown" : 75.0,
		"required_enemy": false,
	},
	{
		# melee excalibur weapon 26
		# affect : melee ally (instant)
		"name": "Resurrect!",
		"icon": preload("res://assets/user_interface/ability/resurection_ability.png"),
		"detail": "Resurrect fallen members in each squad, regardless of allegiance.",
		"type": "melee",
		"weapon_idx": 15,
		"cooldown" : 75.0,
		"required_enemy": false,
	},
	{
		# melee grimhart weapon 27
		# affect : melee enemy (instant)
		# affect : area (instant)
		"name": "Death Mark!",
		"icon": preload("res://assets/user_interface/ability/mark_of_dead_ability.png"),
		"detail": "The curse demands blood before claiming another life. Target suffers -100% Damage Resistance and -80% move speed for 50 seconds. Nearby squads sacrifice a combined 500 HP, distributed evenly among them. The wielder suffers -40% Movement Speed for 15 second after invoking the curse.",
		"type": "melee",
		"weapon_idx": 16,
		"cooldown" : 75.0,
		"required_enemy": false,
	},
	{
		# melee grimhart weapon 28
		# affect : area (instant)
		"name": "Summon!",
		"icon": preload("res://assets/user_interface/ability/summon_ability.png"),
		"detail": "Summon one random squad from your squad pools. required sacrifice HP from nearby unit based on the summoned squad's total health. Summoned squad is Hostile but Not every lost soul returns with hatred (6% chance join your cause). wielder suffers -40% Movement Speed for 15 second after invoking the ritual.",
		"type": "melee",
		"weapon_idx": 16,
		"cooldown" : 75.0,
		"required_enemy": false,
	},
	{
		# range umbriel weapon 29
		# affect : area (indirect)
		"name": "Broken Arrow!",
		"icon": preload("res://assets/user_interface/ability/offmap_trebs_ability.png"),
		"detail": "Signaling an emergency artillery barrage. Nearby trebuchet batteries bombarding random locations around. The bombardment is indiscriminate friend and foe alike.",
		"type": "range",
		"weapon_idx": 6,
		"cooldown" : 75.0,
		"required_enemy": false,
	},
	{
		# range umbriel weapon 30
		# affect : area (instant)
		"name": "Bluff Call!",
		"icon": preload("res://assets/user_interface/ability/abandon_ability.png"),
		"detail": "Squads abandon their positions, believing an trebuchet barrage is imminent. Driven by fear, routing squads gain +15% Movement Speed but have 50% chance suffer +5 emotional damage for 10 seconds.",
		"type": "range",
		"weapon_idx": 6,
		"cooldown" : 75.0,
		"required_enemy": false,
	},
	{
		# melee excalibur weapon 31
		# affect : area (instant)
		"name": "Blinding",
		"icon": preload("res://assets/user_interface/ability/flashbang_ability.png"),
		"detail": "Using divine light to blinds all units on the target tile. All affected squad get -70% Attack Speed & Move speed for 5 seconds",
		"type": "melee",
		"weapon_idx": 15,
		"cooldown" : 40.0,
		"required_enemy": true,
	},
	{
		# melee grimhart weapon 32
		# affect : area (instant)
		"name": "Hypnotic",
		"icon": preload("res://assets/user_interface/ability/hypnotic_ability.png"),
		"detail": "All squads in target tile immediately choose and attack random squad on the map",
		"type": "melee",
		"weapon_idx": 16,
		"cooldown" : 40.0,
		"required_enemy": true,
	},
	{
		# range umbriel weapon 33
		# affect : area (indirect)
		"name": "Rainbolt",
		"icon": preload("res://assets/user_interface/ability/rainbolt_ability.png"),
		"detail": "Calls a long-range ballista strike on the target tile. The bolt may deviate slightly from the intended location. Damages friend and foe alike.",
		"type": "range",
		"weapon_idx": 6,
		"cooldown" : 40.0,
		"required_enemy": true,
	},
	{
		# range siege 34
		# affect : area (on hit)
		"name": "Hornet Nest",
		"icon": preload("res://assets/user_interface/ability/hornet_nest_ability.png"),
		"detail": "Launches a captured hornet nest into the battlefield. The impact causes no direct damage, but enraged hornets swarm every nearby squad, reducing all combat statistics by -25%. The affected area remains infested for 25 seconds, and any squad passing through will also be stung, suffering the same penalty.",
		"type": "siege",
		"weapon_idx": 0, # <- ignore this
		"cooldown" : 60.0,
		"required_enemy": false,
	},
	{
		# range siege weapon 35
		# affect : area (on hit)
		"name": "Splinter",
		"icon": preload("res://assets/user_interface/ability/splinter_ability.png"),
		"detail": "Fires a specially crafted ballista bolt designed to shatter on impact. Razor-sharp wooden splinters burst outward, striking every nearby squad and inflicting Bleeding, causing continuous damage over time.",
		"type": "siege",
		"weapon_idx": 0, # <- ignore this
		"cooldown" : 60.0,
		"required_enemy": false,
	},
	{
		# range siege weapon 36
		# affect : area (on hit)
		"name": "Inferno",
		"icon": preload("res://assets/user_interface/ability/flaming_pot_ability.png"),
		"detail": "Launches a blazing pot of burning pitch that explodes on impact, dealing massive initial damage. The ground ignites for 15 seconds, creating a blazing hazard that sets passing squads ablaze, inflicting Fire damage every second until they escape the flames.",
		"type": "siege",
		"weapon_idx": 0, # <- ignore this
		"cooldown" : 60.0,
		"required_enemy": false,
	},
	{
		# melee spear weapon 37
		# affect : area (instant)
		# affect : enemy (indirect)
		"name": "Tarpit",
		"icon": preload("res://assets/user_interface/ability/tarpit_ability.png"),
		"detail": "Unit pour sticky tar across the target tile. The trap is hidden until triggered. ANY squad entering the tile becomes bogged down, suffering -50% Movement Speed for 10 seconds.",
		"type": "melee",
		"weapon_idx": 2,
		"cooldown" : 40.0,
		"required_enemy": false,
	},
	{
		# range axe weapon 38
		# affect : area (instant)
		# affect : enemy (indirect)
		"name": "Caltrops",
		"icon": preload("res://assets/user_interface/ability/caltrops_ability.png"),
		"detail": "Scatter caltrops onto the target tile. ANY squad entering the tile immediately suffers Bleeding for 10 seconds, and has Movement Speed reduced by -35%. ",
		"type": "range",
		"weapon_idx": 2,
		"cooldown" : 50.0,
		"required_enemy": false,
	},
]

const commander_only_ability = 18
const cavalry_gameplay = 23

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
	preload("res://assets/user_interface/icons/modifier_effect/defence_up.png"),#9
	preload("res://assets/user_interface/icons/modifier_effect/aim_better.png"),#10
	preload("res://assets/user_interface/icons/modifier_effect/slowed.png"),#11
	preload("res://assets/user_interface/icons/modifier_effect/zap.png"),#12
	preload("res://assets/user_interface/icons/modifier_effect/horn.png"),#13
	preload("res://assets/user_interface/icons/modifier_effect/headhurt.png"),#14
	preload("res://assets/user_interface/icons/modifier_effect/bone_break.png"),#15
	preload("res://assets/user_interface/icons/dead.png"),#16
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
const icon_aim_better = 10
const icon_slowed = 11
const icon_zap = 12
const icon_horn = 13
const icon_headhurt = 14
const icon_bonebreak = 15
const icon_death = 16

const sigil_color_red = Color(0.784314, 0, 0)
const sigil_color_purple = Color(0.968627, 0, 1)
const sigil_color_yellow = Color(0.992157, 1, 0)
const sigil_color_cyan = Color(0, 0.882813, 1)

const overtime_damage_scene = preload("res://assets/overtime_damage/overtime_damage.tscn")
const pending_modifier = preload("res://assets/overtime_damage/pending_modifier.tscn")
const pending_stop = preload("res://assets/overtime_damage/pending_stop.tscn")
const tile_trap = preload("res://assets/tile_trap/tile_trap.tscn")

static func use_squad_ability(gameplay, player:PlayerData, squad :BaseSquad, position_manager :TilePositionManager, extra :Dictionary = {}):
	var squad_ability_idx :int = squad.squad_ability_idx
	if squad_ability_idx == 0:
		return
		
	# ability still on cooldown
	if squad.get_ability_cooldown()[0]:
		return
		
	var extra_buff_duration :float = extra.get("extra_buff_duration", 0.0)
	var extra_debuff_duration :float = extra.get("extra_debuff_duration", 0.0)
	var extra_buff_value :float = extra.get("extra_buff_value", 0.0)
	var extra_debuff_value :float = extra.get("extra_debuff_value", 0.0)
	
	match squad_ability_idx:
		1: # stop enemy and -50% speed for them
			var p_modif = pending_modifier.instance()
			p_modif.datas = [[squad.modifier_move_speed, (-0.50 + extra_debuff_value), (15 + extra_debuff_duration), icon_slowed]]
			squad.attach_melee_targets = [p_modif, pending_stop.instance()]
			
		2: # enemy -50% attack speed for 25 sec
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				if squad.is_in_melee_range(enemy):
					var dur = (25 + extra_debuff_duration)
					enemy.set_modifiers([
						[enemy.modifier_melee_speed, (-0.50 + extra_debuff_value), dur, icon_null], # melee attack speed
						[enemy.modifier_range_speed, (-0.50 + extra_debuff_value), dur, icon_zap] # range attack speed 
					])
				
		3: # +50% melee attack speed and +20% movement speed, -25% damage resistance for 15 sec
			var dur = (15 + extra_buff_duration)
			squad.set_modifiers([
				[squad.modifier_melee_speed, (0.50 + extra_buff_value), dur, icon_beserk], # melee attack speed
				[squad.modifier_move_speed, (0.20 + extra_buff_value), dur, icon_null], # movement speed
				[squad.modifier_damage_receive, (0.25 + extra_buff_value), dur, icon_null], # damage receive
			])
			
		4:# +50% range attack speed for 15 sec
			squad.set_modifiers([[squad.modifier_range_speed, (0.50 + extra_buff_value), (15 + extra_buff_duration), icon_buffed]]) # range attack speed 
			
			# -50% speed for enemy on hit
			var p_modif = pending_modifier.instance()
			p_modif.datas = [[squad.modifier_move_speed, (-0.15 + extra_debuff_value), (15 + extra_debuff_duration), icon_slowed]]
			squad.attach_range_targets = [p_modif]
			
			
		5:# +50% speed for 10 sec
			squad.set_modifiers([[squad.modifier_move_speed, (0.50 + extra_buff_value), (10 + extra_buff_duration), icon_move_speed]]) # movement speed
			
		6: # set enemy flee
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				if squad.is_in_melee_range(enemy):
					enemy.set_modifiers([
						[enemy.modifier_move_speed, 0.45, 10, icon_null],
						[enemy.modifier_move_speed, -0.05, 10, icon_scared],
					]) # movement speed
					enemy.retreat()
					
		7: # if enemy got hit -80% move speed for 15 sec
			var p_modif = pending_modifier.instance()
			p_modif.datas = [[squad.modifier_move_speed, (-0.80 + extra_debuff_value), (15 + extra_debuff_duration), icon_slowed]]
			squad.attach_range_targets = [p_modif]
			
		8: # -50% damage receive, -50% attack speed, -75% move speed, for 25 sec
			var dur = (15 + extra_buff_duration)
			squad.set_modifiers([
				[squad.modifier_damage_receive, -0.50, dur, icon_defence_up], # damage receive
				[squad.modifier_melee_speed, -0.50, dur, icon_null], # melee attack speed
				[squad.modifier_range_speed, -0.50, dur, icon_null], # range attack speed 
				[squad.modifier_move_speed, -0.25, dur, icon_null], # movement speed
			])
			
		9: # if enemy got hit -50% range attack speed for enemy
			squad.set_modifiers([ [squad.modifier_range_damage, -0.25, 10, icon_null] ]) # less damage deal
			
			# but debuff enemy on hit
			var p_modif = pending_modifier.instance()
			p_modif.datas = [[squad.modifier_range_speed, -0.50, (10 + extra_debuff_duration), icon_debuffed]]
			squad.attach_range_targets = [p_modif]
			
		10: # -25% damage resistance & 50% slower
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				var dur = (15 + extra_debuff_duration)
				enemy.set_modifiers([
					[enemy.modifier_move_speed, -0.50, dur, icon_null], # movement speed
					[enemy.modifier_damage_receive, 0.25, dur, icon_defence_down], # damage receive
				])
				
		11: # 40% range damage, 50% slowest rate of fire and buff range damage nearby by 10%
			var dur = (15 + extra_buff_duration)
			squad.set_modifiers([
				[squad.modifier_range_damage, 0.40, dur, icon_buffed], # damage deal
				[squad.modifier_range_speed, -0.50, dur, icon_null], #  attack speed 
			])
			
			var ranges :Array = TileMapUtils.get_adjacent_tiles(TileMapUtils.ARROW_DIRECTIONS, squad.current_tile, 1) + [squad.current_tile]
			var squads :Array = _get_squad_in_range(position_manager.get_positions(), ranges)
			for i in squads:
				var s :BaseSquad = i
				if s.team == squad.team and s != squad:
					s.set_modifiers([ [s.modifier_range_damage, 0.10, dur, icon_buffed]])
					
		12: # 40% range damage
			var dur = (10 + extra_buff_duration)
			squad.set_modifiers([
				[squad.modifier_range_damage, 0.40, dur, icon_buffed], # damage deal
			])
			
			var bleed_damage = overtime_damage_scene.instance()
			bleed_damage.damage = int(rand_range(6,8))
			bleed_damage.duration = dur
			bleed_damage.by = squad.get_path()
			squad.attach_melee_targets = [bleed_damage]
				
		13: # -50% range damage, +50% rate of fire
			var dur = (15 + extra_buff_duration)
			squad.set_modifiers([
				[squad.modifier_range_damage, -0.25, dur, icon_null], # damage deal
				[squad.modifier_range_speed, 0.50, dur, icon_buffed], #  attack speed 
			])
			
		14: # 50% melee damage, 50% slowest rate of fire & remove melee speed & movement speed effect (self)
			var dur = (15 + extra_buff_duration)
			var _remove_mods = [ squad.modifier_melee_speed, squad.modifier_move_speed ]
			squad.set_modifiers([
				[squad.modifier_melee_damage, 0.25, dur, icon_null], # damage deal
				[squad.modifier_melee_speed, -0.15, dur, icon_null], # attack speed 
			], _remove_mods)
			
			var bleed_damage = overtime_damage_scene.instance()
			bleed_damage.damage = int(rand_range(4,7))
			bleed_damage.duration = dur
			bleed_damage.by = squad.get_path()
			squad.attach_range_targets = [bleed_damage]
				
		15: # 50% melee damage, 50% slowest rate of fire & weaken anyone in front of it
			var dur = (15 + extra_buff_duration)
			squad.set_modifiers([
				[squad.modifier_melee_damage, 0.50, dur, icon_buffed], # damage deal
				[squad.modifier_melee_speed, -0.50, dur, icon_null], # attack speed 
			])
			
			dur = (15 + extra_debuff_duration)
			var squads :Array = _get_squad_in_range(position_manager.get_positions(), [squad.tile_front()])
			for s in squads:
				s.set_modifiers([[s.modifier_damage_receive, 0.25, dur, icon_defence_down]])
			
		16, 17, 18, 21: # get nearby squads
			var ranges :Array = TileMapUtils.get_adjacent_tiles(TileMapUtils.ARROW_DIRECTIONS, squad.current_tile, 1) + [squad.current_tile]
			var squads :Array = _get_squad_in_range(position_manager.get_positions(), ranges)
			for i in squads:
				var s :BaseSquad = i
				var ability_caster :bool = (s == squad)
				var same_team :bool = s.team == squad.team
				
				var healing_targets = []
				
				match squad_ability_idx:
					16:
						if not ability_caster and same_team:
							s.set_modifiers([ [s.modifier_move_speed, 0.10, 2, icon_heal]]) # just for indicator
							healing_targets.append(s.get_path())
					17:
						if not ability_caster and same_team:
							s.set_modifiers([
								[s.modifier_melee_speed, 0.25, (25 + extra_buff_duration), icon_fist_up], 
								[s.modifier_range_speed, 0.25, (25 + extra_buff_duration), icon_null],
								[s.modifier_move_speed, 0.15, (25 + extra_buff_duration), icon_null],
								[s.modifier_melee_damage, 0.15, (25 + extra_buff_duration), icon_null],
								[s.modifier_range_damage, 0.15, (25 + extra_buff_duration), icon_null],
							])
					18:
						if same_team: # to all ally and yourself
							var _mods = [
								s.modifier_melee_speed,
								s.modifier_range_speed,
								s.modifier_move_speed,
								s.modifier_damage_receive,
								s.modifier_melee_damage,
								s.modifier_range_damage,
							]
							s.set_modifiers([], _mods)
					21:
						if same_team:
							if ability_caster:
								s.set_modifiers([ [s.modifier_melee_speed, 0.30, 15, icon_buffed]]) # just for indicator
								
							else:
								s.set_modifiers([ 
									[s.modifier_melee_speed, 0.10, 15, icon_null],
									[s.modifier_range_speed, 0.10, 15, icon_fist_up]
								])
					
				if not healing_targets.empty():
					gameplay.call_deferred("force_command", 4, healing_targets)
					
		19:# +15% melee speed & enemy 25% melee speed for 10 sec
			squad.set_modifiers([[squad.modifier_melee_speed, 0.15, (10 + extra_buff_duration), icon_buffed]]) # range attack speed 
			
			var p_modif = pending_modifier.instance()
			p_modif.datas = [
				[squad.modifier_damage_receive, (0.15 + extra_debuff_value), (10 + extra_debuff_duration), icon_null],
				[squad.modifier_melee_speed, (-0.15 + extra_debuff_value), (10 + extra_debuff_duration), icon_headhurt]
			]
			squad.attach_melee_targets = [p_modif]
			
		20: # get all squad in enemy tiles
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				var squads :Array = _get_squad_in_range(position_manager.get_positions(), [enemy.current_tile])
				for i in squads:
					var s :BaseSquad = i
					s.set_modifiers([
						[s.modifier_move_speed, (-0.30 + extra_debuff_value), (15 + extra_debuff_duration), icon_null],
						[s.modifier_damage_receive, 0.20, (15 + extra_debuff_duration), icon_null],
						[s.modifier_melee_speed, -0.20, (15 + extra_debuff_duration), icon_bonebreak]
					])
					
		22: # reset enemy cooldown
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				
				# stop, just stop
				if enemy.squad_ability_idx == 0:
					squad.start_ability_cooldown(2.0)
					return 
					
				squad.set_modifiers([[squad.modifier_damage_receive, 0.25, 5, icon_null]]) # damage receive
				enemy.set_modifiers([[enemy.modifier_move_speed, -0.10, 2, icon_zap]]) # just for indicator
				
				enemy.start_ability_cooldown(squad_abilities[enemy.squad_ability_idx]["cooldown"])
				
					
		24: # check if nemey have shield, if do, break them, drop resistance by -60% for 15 sec
			var enemy = squad.enemy
			if is_instance_valid(enemy):
				
				# stop, just stop
				if not enemy.squad_attribute[4]:
					squad.start_ability_cooldown(2.0)
					return 
					
				enemy.set_modifiers([[ enemy.modifier_damage_receive, 0.60, (15 + extra_debuff_duration), icon_defence_down ]])
		
		25,26: # get nearby squads
			var ranges :Array = TileMapUtils.get_adjacent_tiles(TileMapUtils.ARROW_DIRECTIONS, squad.current_tile, 1) + [squad.current_tile]
			var squads :Array = _get_squad_in_range(position_manager.get_positions(), ranges)
			var sigils = []
			
			var _targets = []
			var _type_command = 3 # squad_ability_idx == 25
			
			if squad_ability_idx == 26:
				_type_command = 2
			
			for i in squads:
				var s :BaseSquad = i
				if s.is_hero or (s == squad):
					continue
					
				_targets.append(s.get_path())
				
				match squad_ability_idx:
					25: # reset ability cooldown, ALL
						sigils.append([sigil_color_cyan, s.current_tile, 5.0])
						s.set_modifiers([[s.modifier_move_speed, 0.10, 2, icon_fist_up]]) # just for indicator
						
					26: # resurect
						sigils.append([sigil_color_yellow, s.current_tile, 5.0])
						s.set_modifiers([ [s.modifier_damage_receive, -0.80, 5, icon_heal]]) # just for indicator
			
			gameplay.call_deferred("force_command", _type_command, _targets)
			
			if not sigils.empty():
				gameplay.call_deferred("spawn_sigils", sigils)
				
		27: # put curse
			var enemy = squad.enemy
			var enemy_valid :bool = is_instance_valid(enemy)
			
			var ranges :Array = TileMapUtils.get_adjacent_tiles(TileMapUtils.ARROW_DIRECTIONS, squad.current_tile, 1) + [squad.current_tile]
			var squads :Array = _get_squad_in_range(position_manager.get_positions(), ranges)
			
			if squads.has(squad):
				squads.erase(squad)
				
			if enemy_valid:
				if squads.has(enemy):
					squads.erase(enemy)
				
			if not enemy_valid or squads.empty():
				squad.start_ability_cooldown(10.0)
				return
				
			var sigils :Array = [ [sigil_color_red, enemy.current_tile, 5.0] ]
			var curse :Dictionary = calculate_hp_sacrifice(500, squads)
			
			for squad_data in curse.sacrifice:
				var sac_squad :BaseSquad = squad_data["squad"]
				for member_data in squad_data.members:
					var idx :int = member_data.member_index
					var dmg :int = member_data.damage
					sac_squad.take_damage(dmg, idx, squad.get_path())
					sigils.append([sigil_color_purple, sac_squad.current_tile, 5.0])
					
			var curse_effectivenes :float = curse["curse_effectiveness"]
			var speed_debuff = min(curse_effectivenes + extra_debuff_value, 0.80)
			enemy.set_modifiers([ 
				[enemy.modifier_move_speed, -speed_debuff, (50 + extra_debuff_duration), icon_null],
				[enemy.modifier_damage_receive, curse_effectivenes, (50 + extra_debuff_duration), icon_death]
			])
			
			squad.set_modifiers([[squad.modifier_move_speed, -0.40, 15, icon_slowed]])
			
			gameplay.call_deferred("spawn_sigils", sigils)
			squad.stop()
		
		28: # spawn random crap at random tile position
			var nav :NavTileMap = squad.nav
			var nav_layer :int = squad.nav_layer
			
			var tiles :Array = TileMapUtils.get_astar_adjacent_tile(
				nav.get_astar(nav_layer), nav.get_navigation_id(nav_layer, squad.current_tile), 2
			)
			var target_tile = tiles.pick_random()
			
			if not position_manager.get_positions().has(target_tile):
				squad.start_ability_cooldown(5.0)
				return
				
			var pawn :SquadData = Global.current_squads.pick_random().duplicate()
			pawn.squad_id = -1
			pawn.network_id = 1
			pawn.player_id = "bot_bandit"
			pawn.team = -1
			pawn.squad_name = "Summoned %s" % pawn.squad_name
			pawn.node_name = Utils.create_unique_id()
			pawn.current_tile = target_tile
			pawn.color_idx = 10
			
			# chance will be friend
			if randf() < 0.06:
				pawn.network_id = player.player_network_id
				pawn.player_id = squad.player_id
				pawn.team = squad.team
				pawn.color_idx = player.color_idx
				
			squad.stop()
			
			var ranges :Array = TileMapUtils.get_adjacent_tiles(TileMapUtils.ARROW_DIRECTIONS, squad.current_tile, 1) + [squad.current_tile]
			var squads :Array = _get_squad_in_range(position_manager.get_positions(), ranges)
			
			if squads.has(squad):
				squads.erase(squad)
			
			var hp_cost :int = pawn.member_hp() * pawn.total_member
			var payment :Dictionary = calculate_hp_sacrifice(hp_cost, squads)
			if payment["curse_effectiveness"] < 0.10:
				squad.start_ability_cooldown(10.0)
				return
				
			var sigils :Array = [
				[sigil_color_purple, target_tile, 5.0]
			]
			squad.set_modifiers([[squad.modifier_move_speed, -0.40, 15, icon_horn]])
			
			for squad_data in payment.sacrifice:
				var sac_squad :BaseSquad = squad_data["squad"]
				for member_data in squad_data.members:
					var idx :int = member_data.member_index
					var dmg :int = member_data.damage
					sac_squad.take_damage(dmg, idx, squad.get_path())
					sigils.append([sigil_color_red, sac_squad.current_tile, 5.0])
					
			gameplay.call_deferred("spawn_squad", pawn)
			gameplay.call_deferred("spawn_sigils",sigils)
			
		29: # calling a fking offmap support
			var tiles :Array = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions(), squad.current_tile, 3) + [squad.current_tile]
			var target_tiles = []
			var amount = int(rand_range(12, 24))
			var get_positions = position_manager.get_positions()
			
			squad.set_modifiers([
				[squad.modifier_move_speed, -0.40, 15, icon_null],
				[squad.modifier_move_speed, 0.05, 15, icon_horn]
			])
			
			for _i in amount:
				var t = tiles.pick_random()
				if get_positions.has(t):
					target_tiles.append(t)
				
			gameplay.call_deferred("drop_projectiles", 0, target_tiles, squad.get_path())
			
		30: # force masive retreat
			var ranges :Array = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions(), squad.current_tile, 2) + [squad.current_tile]
			var squads :Array = _get_squad_in_range(position_manager.get_positions(), ranges)
			var targets = []
			for i in squads:
				var s :BaseSquad = i
				if s == squad:
					continue
					
				s.set_modifiers([
					[s.modifier_move_speed, 0.30, 10, icon_null],
					[s.modifier_move_speed, -0.05, 10, icon_scared],
				])
				
				targets.append(s.get_path())
				
			gameplay.call_deferred("force_command", 1, targets)
			
		31,32,33: # check
			var enemy = squad.enemy
			if not is_instance_valid(enemy):
				squad.start_ability_cooldown(10.0)
				return
				
			var ranges :Array = TileMapUtils.get_adjacent_tiles(TileMapUtils.get_directions(), enemy.current_tile, 1) + [enemy.current_tile]
			if squad_ability_idx == 33:
				var target_tiles = []
				var amount = int(rand_range(4, 8))
				for i in amount:
					target_tiles.append(ranges.pick_random())
					
				gameplay.call_deferred("drop_projectiles", 1, target_tiles, squad.get_path())
				
			else:
				var targets = []
				var sigils :Array = []
				
				var squads :Array = _get_squad_in_range(position_manager.get_positions(), ranges)
				for i in squads:
					var s :BaseSquad = i
					if s == squad:
						continue
						
					targets.append(s.get_path())
					
					match squad_ability_idx:
						31:
							sigils.append([sigil_color_yellow, s.current_tile, 5.0])
							s.set_modifiers([
								[s.modifier_melee_speed, -0.70, 5, icon_null],
								[s.modifier_range_speed, -0.70, 5, icon_null],
								[s.modifier_move_speed, -0.70, 5, icon_debuffed],
							])
							
						32:
							s.set_modifiers([
								[s.modifier_move_speed, -0.20, 10, icon_beserk],
								[s.modifier_melee_speed, 0.40, 10, icon_null],
								[s.modifier_range_speed, 0.40, 10, icon_null],
							])
							sigils.append([sigil_color_purple, s.current_tile, 5.0])
						
				gameplay.call_deferred("spawn_sigils", sigils)
				
				if squad_ability_idx == 31:
					gameplay.call_deferred("force_command", 0, targets)
					
				elif squad_ability_idx == 32:
					gameplay.call_deferred("force_command", 5, targets)
					
		34,35,36: # check
			if squad is SiegeEngineSquad:
				squad.use_special_ability()
				squad.set_modifiers([[squad.modifier_move_speed, 0.10, 1, icon_fist_up]])
				
		37,38: # check
			var tile_front :Vector2 = squad.tile_front()
			var on_melee :bool = squad.in_melee_engagement()
			var valid_tile :bool = squad.nav.is_nav_enable(squad.nav_layer, tile_front)
			
			# cannot setup
			if on_melee or not valid_tile:
				squad.start_ability_cooldown(10)
				return
				
			squad.set_modifiers([[squad.modifier_move_speed, 0.05, 1, icon_fist_up]]) # movement speed
			
			var trap = tile_trap.instance()
			trap.duration = 60
			trap.tile = tile_front
			trap.unit_position = position_manager.get_positions()
			
			if squad_ability_idx == 37: # tar pit
				var p_modif = pending_modifier.instance()
				p_modif.datas = [[squad.modifier_move_speed, (-0.50 + extra_debuff_value), (10 + extra_debuff_duration), icon_slowed]]
				trap.attach_targets = [p_modif]
				
			elif squad_ability_idx == 38: # Caltrops
				var p_modif = pending_modifier.instance()
				p_modif.datas = [[squad.modifier_move_speed, (-0.20 + extra_debuff_value), (10 + extra_debuff_duration), icon_bonebreak]]
				
				var bleed_damage = overtime_damage_scene.instance()
				bleed_damage.damage = int(rand_range(8,12))
				bleed_damage.duration = (10 + extra_debuff_duration)
				bleed_damage.by = squad.get_path()
				trap.attach_targets = [p_modif, bleed_damage, pending_stop.instance()]
				
			gameplay.add_child(trap)
			trap.translation = squad.nav.get_pos_v3(tile_front)
			
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
	
	
static func calculate_hp_sacrifice(required_hp :int, squads:Array) -> Dictionary:
	var living_members := []

	# Collect all living members
	for s in squads:
		var squad:BaseSquad = s
		if squad.is_hero:
			continue
			
		var members = squad.get_members(true)
		for i in range(members.size()):
			var member = members[i]
			
			if member.is_dead:
				continue

			living_members.append({
				"squad": squad,
				"member_index": i,
				"remaining_hp": int(member.hp)
			})

	if living_members.empty():
		return {
			"curse_effectiveness": 0.0,
			"sacrifice": []
		}

	# Calculate available HP
	var total_hp := 0
	for m in living_members:
		total_hp += m.remaining_hp

	var sacrifice_hp := min(required_hp, total_hp)
	var effectiveness := float(sacrifice_hp) / float(required_hp)
	
	# squad -> member damages
	var squad_map := {}
	var remaining := sacrifice_hp
	var remaining_members = living_members.duplicate(true)

	while remaining > 0 and remaining_members.size() > 0:
		var share := max(1, int(remaining / remaining_members.size()))
		for i in range(remaining_members.size() - 1, -1, -1):
			if remaining <= 0:
				break
				
			var m = remaining_members[i]
			var damage := min(share, m.remaining_hp)
			if damage <= 0:
				remaining_members.remove(i)
				continue

			m.remaining_hp -= damage
			remaining -= damage

			# Create squad entry
			if !squad_map.has(m.squad):
				squad_map[m.squad] = {}

			# Accumulate damage on same member
			if !squad_map[m.squad].has(m.member_index):
				squad_map[m.squad][m.member_index] = 0

			squad_map[m.squad][m.member_index] += damage

			if m.remaining_hp <= 0:
				remaining_members.remove(i)

	# Convert to requested format
	var sacrifice := []
	for squad in squad_map.keys():
		var members := []
		for member_index in squad_map[squad].keys():
			members.append({
				"member_index": member_index,
				"damage": squad_map[squad][member_index]
			})

		sacrifice.append({
			"squad": squad,
			"members": members
		})

	return {
		"curse_effectiveness": effectiveness,
		"sacrifice": sacrifice
	}









