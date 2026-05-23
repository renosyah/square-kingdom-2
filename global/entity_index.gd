extends Node
class_name EntityIndex

const squads = [
	preload("res://scenes/tile_units/squad/infantry_squad/infantry_squad.tscn")
]
const members = [
	preload("res://scenes/tile_units/squad_member/infantry_member/infantry_member.tscn")
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
	preload("res://scenes/equipment/weapons/throwing_axe/throwing_axe.tscn") #12
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
	preload("res://assets/user_interface/icons/pitch_fork.png"), #0
	preload("res://assets/user_interface/icons/spear.png"), #1
	preload("res://assets/user_interface/icons/melee.png"), #2
	preload("res://assets/user_interface/icons/range.png"), #3
	preload("res://assets/user_interface/icons/axe.png"), #4
	preload("res://assets/user_interface/icons/special.png"), #5
	preload("res://assets/user_interface/icons/commander.png") #6
]
const squad_potraits = [
	preload("res://assets/user_interface/squad_potrait/peasant.png"), #0
	preload("res://assets/user_interface/squad_potrait/militia.png"), #1
	preload("res://assets/user_interface/squad_potrait/merc_1.png"), #2
	preload("res://assets/user_interface/squad_potrait/merc_2.png"), #3
	preload("res://assets/user_interface/squad_potrait/reguler_1.png"), #4
	preload("res://assets/user_interface/squad_potrait/reguler_2.png"), #5
	preload("res://assets/user_interface/squad_potrait/reguler_3.png"), #6
	preload("res://assets/user_interface/squad_potrait/knight_1.png"), #7
	preload("res://assets/user_interface/squad_potrait/knight_2.png"), #8
	preload("res://assets/user_interface/squad_potrait/knight_3.png") #9
]
