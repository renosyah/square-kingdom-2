extends Node
class_name EntityIndex

const squads = [
	preload("res://scenes/tile_units/squad/infantry_squad/infantry_squad.tscn"),#0
	preload("res://scenes/tile_units/squad/cavalry_squad/cavalry_squad.tscn"),#1
	
	# siege engines
	preload("res://scenes/tile_units/squad/siege_engine_squad/catapult_squad.tscn"),#2
	preload("res://scenes/tile_units/squad/siege_engine_squad/balista_squad.tscn"),#3
	preload("res://scenes/tile_units/squad/siege_engine_squad/trebuchet_squad.tscn")#4
]
const members = [
	preload("res://scenes/tile_units/squad_member/infantry_member/infantry_member.tscn"),
	preload("res://scenes/tile_units/squad_member/cavalry_member/cavalry_member.tscn")
]
const weapons = [
	null, # index 0 as NULL 0
	preload("res://scenes/equipment/weapons/dagger/dagger.tscn"), #1
	preload("res://scenes/equipment/weapons/pitchfork/pitchfork.tscn"), #2
	preload("res://scenes/equipment/weapons/spear/spear.tscn"), #3
	preload("res://scenes/equipment/weapons/spear/spear_shield.tscn"), #4
	preload("res://scenes/equipment/weapons/pike/pike.tscn"), #5
	preload("res://scenes/equipment/weapons/sword/sword.tscn"), #6
	preload("res://scenes/equipment/weapons/sword/sword_shield.tscn"), #7
	preload("res://scenes/equipment/weapons/axe/axe.tscn"), #8
	preload("res://scenes/equipment/weapons/axe/axe_shield.tscn"), #9
	preload("res://scenes/equipment/weapons/bow/bow.tscn"), #10
	preload("res://scenes/equipment/weapons/longbow/longbow.tscn"), #11
	preload("res://scenes/equipment/weapons/throwing_axe/throwing_axe.tscn"), #12
	preload("res://scenes/equipment/weapons/javeline/javelin.tscn"), #13
	preload("res://scenes/equipment/weapons/crossbow/crossbow.tscn"), #14
]
const equipment = [
	null, # index 0 as NULL
	
	# shield
	preload("res://scenes/equipment/shield/shield.tscn"),#1
	preload("res://scenes/equipment/shield/shield_round.tscn"),#2
	
	# headgear
	preload("res://scenes/equipment/headgear/cape/cape.tscn"), #3
	preload("res://scenes/equipment/headgear/helm/helm.tscn"), #4
	preload("res://scenes/equipment/headgear/helm/helm_2.tscn"), #5
	preload("res://scenes/equipment/headgear/helm/helm_3.tscn"), #6
	preload("res://scenes/equipment/headgear/kettle/kettle.tscn"), #7
	
	# armor
	preload("res://scenes/equipment/armor/leather_armor/leather_armor.tscn"), #8
	preload("res://scenes/equipment/armor/plate_armor/plate_armor.tscn"), #9
	
]
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
	preload("res://assets/user_interface/squad_potrait/cavalry/royal_cav.png"), #15
	
	preload("res://assets/user_interface/squad_potrait/siege_engine/catapult.png"),#16
	preload("res://assets/user_interface/squad_potrait/siege_engine/balista.png"),#17
	preload("res://assets/user_interface/squad_potrait/siege_engine/ram.png"),#18
	preload("res://assets/user_interface/squad_potrait/siege_engine/siege_tower.png"),#19
	preload("res://assets/user_interface/squad_potrait/siege_engine/trebuchet.png")#20
	
]

const player_potraits = [
	preload("res://assets/user_interface/potrait/1.png"),
	preload("res://assets/user_interface/potrait/2.png"),
	preload("res://assets/user_interface/potrait/3.png"),
	preload("res://assets/user_interface/potrait/4.png"),
	preload("res://assets/user_interface/potrait/5.png"),
	preload("res://assets/user_interface/potrait/6.png"),
	preload("res://assets/user_interface/potrait/7.png"),
	preload("res://assets/user_interface/potrait/8.png"),
	preload("res://assets/user_interface/potrait/9.png")
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
	Color.black
]
