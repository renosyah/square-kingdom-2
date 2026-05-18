extends Node
class_name EntityIndex

const squads = [
	preload("res://scenes/tile_units/squad/infantry_squad/infantry_squad.tscn")
]
const members = [
	preload("res://scenes/tile_units/squad_member/infantry_member/infantry_member.tscn")
]
const weapons = [
	null, # index 0 as NULL
	preload("res://scenes/equipment/weapons/dagger/dagger.tscn"),
	preload("res://scenes/equipment/weapons/spear/spear.tscn"),
	preload("res://scenes/equipment/weapons/spear/spear_shield.tscn"),
	preload("res://scenes/equipment/weapons/sword/sword.tscn"),
	preload("res://scenes/equipment/weapons/sword/sword_shield.tscn"),
	
	preload("res://scenes/equipment/weapons/bow/bow.tscn")
]
const equipment = [
	null, # index 0 as NULL
	preload("res://scenes/equipment/shield/shield.tscn")
]
