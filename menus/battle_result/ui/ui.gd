extends Control

const victory = preload("res://assets/background/victory.png")
const lost = preload("res://assets/background/lost.png")

const victory_wording = [
	"Victory!","Let us celebrate!",
	"For the king!", "We Win!", "What a battle!"
]
const lost_wording = [
	"Defeated","Battle is Lost",
	"Lossing", "Sad day", "What a disaster"
]
onready var scoreboard = $CanvasLayer2/Control/scoreboard
onready var texture_rect = $CanvasLayer2/Control/TextureRect
onready var title = $CanvasLayer2/Control/VBoxContainer/MarginContainer2/MarginContainer4/HBoxContainer/MarginContainer/title

func _ready():
	var is_win :bool = Global.is_win
	texture_rect.texture = victory if is_win else lost
	title.text = victory_wording.pick_random() if is_win else lost_wording.pick_random()
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	Global.hide_transition()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:

			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			return
			
func _on_scoreboard_pressed():
	scoreboard.visible = true

func _on_to_lobby_pressed():
	Global.change_scene("res://menus/lobby/lobby.tscn", true)
	
func _on_scoreboard_close():
	scoreboard.visible = false
