extends BaseGameplay

onready var infantry_squad = $infantry_squad
onready var infantry_squad_2 = $infantry_squad2
onready var infantry_squad_3 = $infantry_squad3

func _on_tile_map_ready():
	._on_tile_map_ready()
	
	infantry_squad.nav = nav
	infantry_squad_2.nav = nav
	infantry_squad_3.nav = nav
