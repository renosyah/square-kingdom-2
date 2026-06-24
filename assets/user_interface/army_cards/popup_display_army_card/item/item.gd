extends MarginContainer

const rarity_colors = [
	Color("#808080"),
	Color("#36A90C"),
	Color("#1E7FB7"),
	Color("#832EF7"),
	Color("#FFD700"),
]

var card :ArmyCardData

onready var title = $MarginContainer/VBoxContainer/HBoxContainer/title
onready var icon =  $MarginContainer/VBoxContainer/MarginContainer/icon
onready var detail =  $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer2/MarginContainer2/detail
onready var color_rect_2 = $ColorRect2
onready var color_rect_3 = $MarginContainer/ColorRect3
onready var color_rect = $MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/ColorRect
onready var texture_rect = $MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/TextureRect

func _ready():
	title.text = card.card_name
	icon.texture = EntityIndex.army_cards[card.icon_index]
	detail.text = card.get_detail()
	color_rect_2.color = rarity_colors[card.rarity]
	color_rect.color = rarity_colors[card.rarity]
	texture_rect.texture = AbilityHandle.buff_debuff_icons[AbilityHandle.icon_fist_up] if card.is_buff else preload("res://assets/user_interface/icons/dead.png") 
