extends Tile2D

onready var sprite = $Sprite

func _ready():
	match (biom):
		0:
			sprite.color = Color(0.031373, 0.407843, 0)
		1:
			sprite.color = Color(0.635294, 0.403922, 0)
		2:
			sprite.color = Color(0.592157, 0.592157, 0.592157)
