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

onready var buf_container = $MarginContainer/VBoxContainer/HBoxContainer/buf_container
onready var debuff_container = $MarginContainer/VBoxContainer/HBoxContainer/debuff_container

onready var icon_bgs = [
	$MarginContainer/VBoxContainer/HBoxContainer/buf_container/Control/MarginContainer/ColorRect,
	$MarginContainer/VBoxContainer/HBoxContainer/debuff_container/ColorRect
]

func _ready():
	if card:
		title.text = card.card_name
		icon.texture = EntityIndex.army_cards[card.icon_index]
		detail.text = card.get_detail()
		detail.modulate = Color.green if card.is_buff else Color.red
		color_rect_2.color = rarity_colors[card.rarity]
		
		buf_container.visible = card.is_buff
		debuff_container.visible = not card.is_buff
		
		for i in icon_bgs:
			i.color = rarity_colors[card.rarity]

