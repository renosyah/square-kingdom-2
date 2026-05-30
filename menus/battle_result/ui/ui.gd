extends Control

const victory = preload("res://assets/background/victory.png")
const lost = preload("res://assets/background/lost.png")

const victory_wording = [
	["Victory", "The kingdom stands victorious."],
	["Triumph", "Let the bells ring across the realm."],
	["Decisive Victory", "The enemy has been routed."],
	["Glorious Victory", "Our banners fly proudly over the battlefield."],
	["The Crown Prevails", "The realm prospers through strength and resolve."],
	["A Good Day for the Kingdom", "The scribes will remember this one."],
	["Total Domination", "No enemy remains to challenge us."],
	["A Song Worth Singing", "The bards shall tell of this victory for generations."],
]
const lost_wording = [
	["Defeat", "The battle has been lost."],
	["A Bitter Defeat", "Many brave souls will not return home."],
	["Retreat", "Our forces have been forced from the field."],
	["A Dark Day", "The kingdom mourns its fallen."],
	["The Crown Falters", "The realm must endure this setback."],
	["The Field is Lost", "The enemy now claims the battlefield."],
	["Defeat Today, Victory Tomorrow", "The war is not yet over."],
	["That Could Have Gone Better", "The treasury will not enjoy this report."],
]
onready var scoreboard = $CanvasLayer2/Control/scoreboard
onready var texture_rect = $CanvasLayer2/Control/TextureRect
onready var title = $CanvasLayer2/Control/VBoxContainer/MarginContainer2/MarginContainer4/HBoxContainer/MarginContainer/VBoxContainer/title
onready var desc = $CanvasLayer2/Control/VBoxContainer/MarginContainer2/MarginContainer4/HBoxContainer/MarginContainer/VBoxContainer/desc

func _ready():
	var is_win :bool = Global.is_win
	texture_rect.texture = victory if is_win else lost
	var wordings =  victory_wording.pick_random() if is_win else lost_wording.pick_random()
	title.text = wordings[0]
	desc.text = wordings[1]
	
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
