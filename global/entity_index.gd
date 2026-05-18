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
	preload("res://scenes/equipment/weapons/sword/sword.tscn"), #5
	preload("res://scenes/equipment/weapons/sword/sword_shield.tscn"), #6
	
	preload("res://scenes/equipment/weapons/axe/axe.tscn"), #7
	preload("res://scenes/equipment/weapons/axe/axe_shield.tscn"), #8
	
	preload("res://scenes/equipment/weapons/bow/bow.tscn") #9
]
const equipment = [
	null, # index 0 as NULL
	preload("res://scenes/equipment/shield/shield.tscn")
]
const squad_icon = [
	preload("res://assets/user_interface/icons/pitch_fork.png"), #0
	preload("res://assets/user_interface/icons/spear.png"), #1
	preload("res://assets/user_interface/icons/melee.png"), #2
	preload("res://assets/user_interface/icons/range.png"), #3
	preload("res://assets/user_interface/icons/axe.png") #4
	
]
