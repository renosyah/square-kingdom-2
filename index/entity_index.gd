extends Node
class_name EntityIndex

const squads = [
	# infantry & cavalry
	preload("res://scenes/tile_units/squad/infantry_squad/infantry_squad.tscn"),#0
	preload("res://scenes/tile_units/squad/cavalry_squad/cavalry_squad.tscn"),#1
	
	# siege engines
	preload("res://scenes/tile_units/squad/siege_engine_squad/catapult_squad.tscn"),#2
	preload("res://scenes/tile_units/squad/siege_engine_squad/balista_squad.tscn"),#3
	preload("res://scenes/tile_units/squad/siege_engine_squad/trebuchet_squad.tscn"),#4
	
	# tower
	preload("res://scenes/tile_units/squad/guard_tower_squad/guard_tower_squad.tscn")#5
]
const members = [
	preload("res://scenes/tile_units/squad_member/infantry_member/infantry_member.tscn"), #0
	preload("res://scenes/tile_units/squad_member/cavalry_member/cavalry_member.tscn") #1
]

const melee_weapons = [
	preload("res://scenes/equipment/weapons/dagger/dagger.tscn"), #0
	preload("res://scenes/equipment/weapons/pitchfork/pitchfork.tscn"), #1
	preload("res://scenes/equipment/weapons/spear/spear.tscn"), #2
	preload("res://scenes/equipment/weapons/spear/spear_shield.tscn"), #3
	preload("res://scenes/equipment/weapons/pike/pike.tscn"), #4
	preload("res://scenes/equipment/weapons/sword/sword.tscn"), #5
	preload("res://scenes/equipment/weapons/sword/sword_shield.tscn"), #6
	preload("res://scenes/equipment/weapons/axe/axe.tscn"), #7
	preload("res://scenes/equipment/weapons/axe/axe_shield.tscn"), #8
	preload("res://scenes/equipment/weapons/great_axe/great_axe.tscn"), #9
	preload("res://scenes/equipment/weapons/great_sword/great_sword.tscn"), #10
	preload("res://scenes/equipment/weapons/sword/sword_curve.tscn"), #11
	preload("res://scenes/equipment/weapons/sword/sword_curve_shield.tscn"), #12
	preload("res://scenes/equipment/weapons/mace/mace.tscn"), #13
	preload("res://scenes/equipment/weapons/warhammer/warhammer.tscn"), #14
	preload("res://scenes/equipment/weapons/great_sword/excalibur.tscn"), #15
	preload("res://scenes/equipment/weapons/pike/grimhart.tscn"), #16
	
]
# weapon attack speed
const melee_weapon_stats = {
	0:{'attack_speed':0.45,'charge_bonus':0,'spawn_time':3},
	1:{'attack_speed':1.92,'charge_bonus':2,'spawn_time':2},
	2:{'attack_speed':0.81,'charge_bonus':9,'spawn_time':4},
	3:{'attack_speed':0.92,'charge_bonus':7,'spawn_time':4},
	4:{'attack_speed':0.75,'charge_bonus':12,'spawn_time':6},
	5:{'attack_speed':0.57,'charge_bonus':0,'spawn_time':5},
	6:{'attack_speed':0.68,'charge_bonus':0,'spawn_time':5},
	7:{'attack_speed':0.87,'charge_bonus':0,'spawn_time':7},
	8:{'attack_speed':1.85,'charge_bonus':0,'spawn_time':7},
	9:{'attack_speed':1.98,'charge_bonus':8,'spawn_time':8},
	10:{'attack_speed':1.78,'charge_bonus':7,'spawn_time':9},
	11:{'attack_speed':0.78,'charge_bonus':0,'spawn_time':6},
	12:{'attack_speed':0.65,'charge_bonus':0,'spawn_time':6},
	13:{'attack_speed':0.64,'charge_bonus':0,'spawn_time':5},
	14:{'attack_speed':1.38,'charge_bonus':0,'spawn_time':8},
	15:{'attack_speed':0.88,'charge_bonus':6,'spawn_time':4},
	16:{'attack_speed':0.997,'charge_bonus':8,'spawn_time':7},
}

const range_weapons = [
	null, # index 0 as NULL 0
	preload("res://scenes/equipment/weapons/javeline/javelin.tscn"), #1
	preload("res://scenes/equipment/weapons/throwing_axe/throwing_axe.tscn"), #2
	preload("res://scenes/equipment/weapons/bow/bow.tscn"), #3
	preload("res://scenes/equipment/weapons/longbow/longbow.tscn"), #4
	preload("res://scenes/equipment/weapons/crossbow/crossbow.tscn"), #5
	preload("res://scenes/equipment/weapons/bow/auriel.tscn"), #6
]
const range_weapon_stats = {
	0:{'range':1,'attack_speed':0.1,'spawn_time':1}, # 1 default
	1:{'range':3,'attack_speed':1.8,'spawn_time':2},
	2:{'range':2,'attack_speed':1.55,'spawn_time':3},
	3:{'range':4,'attack_speed':1.8,'spawn_time':4},
	4:{'range':6,'attack_speed':2.86,'spawn_time':6},
	5:{'range':4,'attack_speed':4.85,'spawn_time':5},
	6:{'range':6,'attack_speed':0.45,'spawn_time':2},
}

const head_armors = [
	null, # index 0 as NULL
	preload("res://scenes/equipment/headgear/cape/cape.tscn"), #1
	preload("res://scenes/equipment/headgear/kettle/kettle.tscn"), #2
	preload("res://scenes/equipment/headgear/helm/helm.tscn"), #3
	preload("res://scenes/equipment/headgear/helm/helm_2.tscn"), #4
	preload("res://scenes/equipment/headgear/helm/helm_3.tscn"), #5
	preload("res://scenes/equipment/headgear/helm/arabian_helm_1.tscn"), #6
	preload("res://scenes/equipment/headgear/helm/arabian_helm_2.tscn"), #7
	preload("res://scenes/equipment/headgear/cape/hood.tscn"),#8
	preload("res://scenes/equipment/headgear/cape/hood_white.tscn"),#9
	preload("res://scenes/equipment/headgear/helm/helm_3_cross.tscn"),#10
	preload("res://scenes/equipment/headgear/helm/helm_3_cross_horn.tscn"),#11
	preload("res://scenes/equipment/headgear/helm/helm_crown.tscn"),#12
	preload("res://scenes/equipment/headgear/helm/helm_4.tscn"),#13
	preload("res://scenes/equipment/headgear/helm/helm_5.tscn"),#14
]
const head_armors_stats = {
	0:{'hp':0,'speed':0,'spawn_time':1},
	1:{'hp':5,'speed':0,'spawn_time':1},
	2:{'hp':12,'speed':-0.012,'spawn_time':2},
	3:{'hp':22,'speed':-0.023,'spawn_time':3},
	4:{'hp':23,'speed':-0.035,'spawn_time':3},
	5:{'hp':28,'speed':-0.062,'spawn_time':4},
	6:{'hp':11,'speed':-0.008,'spawn_time':2},
	7:{'hp':24,'speed':-0.015,'spawn_time':2},
	8:{'hp':5,'speed':0,'spawn_time':1},
	9:{'hp':5,'speed':0,'spawn_time':1},
	10:{'hp':28,'speed':-0.062,'spawn_time':4},
	11:{'hp':35,'speed':-0.068,'spawn_time':5},
	12:{'hp':12,'speed':-0.008,'spawn_time':2},
	13:{'hp':27,'speed':-0.067,'spawn_time':4},
	14:{'hp':28,'speed':-0.065,'spawn_time':4},
}

const heavy_armor_idxs = [2, 5]

const armors = [
	null, # index 0 as NULL
	preload("res://scenes/equipment/armor/leather_armor/leather_armor.tscn"), #1
	preload("res://scenes/equipment/armor/plate_armor/plate_armor.tscn"), #2
	preload("res://scenes/equipment/armor/medium_armor/medium_armor.tscn"), #3
	preload("res://scenes/equipment/armor/leather_armor/leather_armor_cross.tscn"), #4
	preload("res://scenes/equipment/armor/plate_armor/plate_armor_cross.tscn"), #5
]
const armors_stats = {
	0:{'hp':0,'speed':0,'mass':0,'spawn_time':1},
	1:{'hp':45,'speed':-0.08,'mass':0.4,'spawn_time':4},
	2:{'hp':165,'speed':-0.13,'mass':2.6,'spawn_time':8},
	3:{'hp':85,'speed':-0.09,'mass':1.6,'spawn_time':6},
	4:{'hp':50,'speed':-0.06,'mass':1.5,'spawn_time':5},
	5:{'hp':165,'speed':-0.13,'mass':2.6,'spawn_time':8},
}

const shields = [
	null, # index 0 as NULL
	preload("res://scenes/equipment/shield/shield.tscn"),#1
	preload("res://scenes/equipment/shield/shield_round.tscn"),#2
	preload("res://scenes/equipment/shield/shield_cross.tscn"),#3
	preload("res://scenes/equipment/shield/shield_kite.tscn"),#4
	preload("res://scenes/equipment/shield/shield_kite_cross.tscn"),#5
]
const shield_stats = {
	0:{'hp':0,'speed':0,'spawn_time':1},
	1:{'hp':35,'speed':-0.07,'spawn_time':4},
	2:{'hp':15,'speed':-0.06,'spawn_time':3},
	3:{'hp':35,'speed':-0.07,'spawn_time':4},
	4:{'hp':13,'speed':-0.05,'spawn_time':3},
	5:{'hp':13,'speed':-0.05,'spawn_time':3},
}

const squad_icon = [
	preload("res://assets/user_interface/icons/squad/pitch_fork.png"), #0
	preload("res://assets/user_interface/icons/squad/spear.png"), #1
	preload("res://assets/user_interface/icons/squad/melee.png"), #2
	preload("res://assets/user_interface/icons/squad/range.png"), #3
	preload("res://assets/user_interface/icons/squad/axe.png"), #4
	preload("res://assets/user_interface/icons/squad/special.png"), #5
	preload("res://assets/user_interface/icons/squad/commander.png"),#6
	preload("res://assets/user_interface/icons/squad/javeline.png"), #7
	preload("res://assets/user_interface/icons/squad/crossbow.png"),  #8
	preload("res://assets/user_interface/icons/squad/catapult.png"), #9
	preload("res://assets/user_interface/icons/squad/balista.png"),#10
	preload("res://assets/user_interface/icons/squad/trebuchet.png"),#11
	preload("res://assets/user_interface/icons/squad/hero.png"),#12
	preload("res://assets/user_interface/icons/squad/light.png"),#13
	preload("res://assets/user_interface/icons/squad/shield.png"),#14
	preload("res://assets/user_interface/icons/squad/hammer.png"),#15
	preload("res://assets/user_interface/icons/squad/axe_2.png"),
	preload("res://assets/user_interface/icons/squad/hammer_2.png"),
	preload("res://assets/user_interface/icons/squad/mace.png"),
]
const squad_potraits = [
	preload("res://assets/user_interface/squad_potrait/infantry/peasant.png"), #0
	preload("res://assets/user_interface/squad_potrait/infantry/militia.png"), #1
	preload("res://assets/user_interface/squad_potrait/infantry/merc_1.png"), #2
	preload("res://assets/user_interface/squad_potrait/infantry/merc_2.png"), #3
	preload("res://assets/user_interface/squad_potrait/infantry/merc_3.png"), #4
	preload("res://assets/user_interface/squad_potrait/infantry/reguler_1.png"), #5
	preload("res://assets/user_interface/squad_potrait/infantry/reguler_2.png"), #6
	preload("res://assets/user_interface/squad_potrait/infantry/reguler_3.png"), #7
	preload("res://assets/user_interface/squad_potrait/infantry/reguler_4.png"), #8
	preload("res://assets/user_interface/squad_potrait/infantry/knight_1.png"), #9
	preload("res://assets/user_interface/squad_potrait/infantry/knight_2.png"), #10
	preload("res://assets/user_interface/squad_potrait/infantry/knight_3.png"), #11
	preload("res://assets/user_interface/squad_potrait/cavalry/spear_cav.png"), #12
	preload("res://assets/user_interface/squad_potrait/cavalry/sword_cav.png"), #13
	preload("res://assets/user_interface/squad_potrait/cavalry/archer_cav.png"), #14
	preload("res://assets/user_interface/squad_potrait/cavalry/heavy_spear_cav.png"),#15
	preload("res://assets/user_interface/squad_potrait/cavalry/heavy_sword_cav.png"),#16
	preload("res://assets/user_interface/squad_potrait/cavalry/royal_cav.png"), #17
	preload("res://assets/user_interface/squad_potrait/siege_engine/catapult.png"),#18
	preload("res://assets/user_interface/squad_potrait/siege_engine/balista.png"),#19
	preload("res://assets/user_interface/squad_potrait/siege_engine/trebuchet.png"),#20
	preload("res://assets/user_interface/squad_potrait/siege_engine/ram.png"),#21
	preload("res://assets/user_interface/squad_potrait/siege_engine/siege_tower.png"),#22
	preload("res://assets/user_interface/squad_potrait/infantry/arabian_archer.png"),#23
	preload("res://assets/user_interface/squad_potrait/infantry/arabian_spearman.png"),#24
	preload("res://assets/user_interface/squad_potrait/infantry/arabian_swordman.png"),#25

	preload("res://assets/user_interface/potrait/1.png"),
	preload("res://assets/user_interface/potrait/2.png"),
	preload("res://assets/user_interface/potrait/3.png"),
	preload("res://assets/user_interface/potrait/4.png"),
	preload("res://assets/user_interface/potrait/5.png"),
	preload("res://assets/user_interface/potrait/6.png"),
	preload("res://assets/user_interface/potrait/7.png"),
	preload("res://assets/user_interface/potrait/8.png"),
	preload("res://assets/user_interface/potrait/9.png"),
	preload("res://assets/user_interface/potrait/10.png"),
	preload("res://assets/user_interface/potrait/11.png"),
	preload("res://assets/user_interface/potrait/12.png"),
	preload("res://assets/user_interface/potrait/13.png"),
	preload("res://assets/user_interface/potrait/14.png"),
	preload("res://assets/user_interface/potrait/15.png"),
	preload("res://assets/user_interface/potrait/16.png"),
	preload("res://assets/user_interface/potrait/17.png"),
	preload("res://assets/user_interface/potrait/18.png"),
	preload("res://assets/user_interface/potrait/19.png"),
	preload("res://assets/user_interface/potrait/20.png"),
	preload("res://assets/user_interface/potrait/22.png"),
	preload("res://assets/user_interface/potrait/23.png"),
	preload("res://assets/user_interface/potrait/24.png"),
	preload("res://assets/user_interface/potrait/25.png"),
	preload("res://assets/user_interface/potrait/26.png"),
	preload("res://assets/user_interface/potrait/27.png"),
	preload("res://assets/user_interface/potrait/28.png"), 
	preload("res://assets/user_interface/potrait/29.png"), 
	preload("res://assets/user_interface/potrait/30.png"), 
	preload("res://assets/user_interface/potrait/31.png"), 
	preload("res://assets/user_interface/potrait/32.png"), 
	preload("res://assets/user_interface/potrait/33.png"), 
	preload("res://assets/user_interface/potrait/34.png"), 
	preload("res://assets/user_interface/potrait/35.png"), 
	preload("res://assets/user_interface/potrait/36.png"), 
	preload("res://assets/user_interface/potrait/37.png"), 
	preload("res://assets/user_interface/potrait/38.png"), 
	preload("res://assets/user_interface/potrait/39.png"), 
	preload("res://assets/user_interface/potrait/40.png"), 
	preload("res://assets/user_interface/potrait/41.png"), 
	preload("res://assets/user_interface/potrait/42.png"), 
	preload("res://assets/user_interface/potrait/43.png"),
	preload("res://assets/user_interface/potrait/44.png"),
	preload("res://assets/user_interface/potrait/45.png"),
	preload("res://assets/user_interface/potrait/46.png"),
	preload("res://assets/user_interface/potrait/47.png"),
	preload("res://assets/user_interface/potrait/48.png"),
	preload("res://assets/user_interface/potrait/49.png"),
	preload("res://assets/user_interface/potrait/50.png"),
	preload("res://assets/user_interface/potrait/51.png"),
	preload("res://assets/user_interface/potrait/52.png")
]

const army_cards = [
	# buff list
	preload("res://assets/user_interface/army_cards/buff/army_tradition.png"), #0
	preload("res://assets/user_interface/army_cards/buff/arrow_drill_card.png"), #1
	preload("res://assets/user_interface/army_cards/buff/camp_healer_card.png"), #2
	preload("res://assets/user_interface/army_cards/buff/combat_training_card.png"), #3
	preload("res://assets/user_interface/army_cards/buff/field_hospital_card.png"), #4
	preload("res://assets/user_interface/army_cards/buff/fletcher_guild_card.png"), #5
	preload("res://assets/user_interface/army_cards/buff/force_march_card.png"), #6
	preload("res://assets/user_interface/army_cards/buff/hardy_folk_card.png"), #7
	preload("res://assets/user_interface/army_cards/buff/master_archer_card.png"), #8
	preload("res://assets/user_interface/army_cards/buff/mercenary_company_card.png"), #9
	preload("res://assets/user_interface/army_cards/buff/season_veteran_card.png"), #10
	preload("res://assets/user_interface/army_cards/buff/singing_march_card.png"), #11
	preload("res://assets/user_interface/army_cards/buff/stamina_training_card.png"), #12
	preload("res://assets/user_interface/army_cards/buff/strong_constitution_card.png"), #13
	preload("res://assets/user_interface/army_cards/buff/swift_advance_card.png"), #14
	preload("res://assets/user_interface/army_cards/buff/veteran_survivor_card.png"), #15
	preload("res://assets/user_interface/army_cards/buff/veteran_warrior_card.png"), #16
	
	# debuff
	preload("res://assets/user_interface/army_cards/debuff/attrition_card.png"), #17
	preload("res://assets/user_interface/army_cards/debuff/bad_weather_card.png"), #18
	preload("res://assets/user_interface/army_cards/debuff/bogdown_card.png"), #19
	preload("res://assets/user_interface/army_cards/debuff/demoralise_card.png"), #20
	preload("res://assets/user_interface/army_cards/debuff/disorganize_card.png"), #21
	preload("res://assets/user_interface/army_cards/debuff/exhaustion_card.png"), #22
	preload("res://assets/user_interface/army_cards/debuff/hunger_card.png"), #23
	preload("res://assets/user_interface/army_cards/debuff/outnumber_card.png"), #24
	preload("res://assets/user_interface/army_cards/debuff/sickness_card.png"), #25
	preload("res://assets/user_interface/army_cards/debuff/supply_shortage_card.png"), #26
	preload("res://assets/user_interface/army_cards/debuff/thirst_card.png") #27
]

const player_colors = [
	Color("#2B5D9D"),
	Color("#982D2D"),
	Color("#583591"),
	Color("#31753F"),
	Color("#AD7F1D"),
	Color("#36A1B8"),
	Color("#B8541B"),
	Color("#B14C7E"),
	Color("#585F69"),
	Color.black,
	Color("#652d00")
]


