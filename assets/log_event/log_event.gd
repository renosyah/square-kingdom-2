extends MarginContainer

onready var list = $VBoxContainer
onready var temp = $temp
onready var timer = $Timer

func _ready():
	timer.start()

func add_log_damage(squad :BaseSquad, amount :int):
	var from :BaseSquad = get_node_or_null(squad.attacked_by)
	if not from:
		return
		
	var arr = [squad.color.to_html(),squad.unit_name,from.color.to_html(),from.unit_name, amount]
	add_log("[DMG] [color=#%s]%s[/color] struck by [color=#%s]%s[/color] for [color=red]%s[/color] damage" % arr)
	
func add_log_member_lost(squad :BaseSquad):

	var from :BaseSquad = get_node_or_null(squad.attacked_by)
	if not from:
		return
		
	var arr = [squad.color.to_html(),squad.unit_name,from.color.to_html(),from.unit_name]
	add_log("[LOSS] [color=#%s]%s[/color] lost 1 men from [color=#%s]%s[/color]" % arr)
	
func add_log_squad_dead(squad :BaseSquad):

	var from :BaseSquad = get_node_or_null(squad.attacked_by)
	if not from:
		return
		
	var arr = [squad.color.to_html(),squad.unit_name,from.color.to_html(),from.unit_name]
	add_log("[DESTROYED] [color=#%s]%s[/color] Destroyed by [color=#%s]%s[/color]" % arr)

func add_log(text :String):
	var l :RichTextLabel = temp.duplicate()
	l.visible = true
	l.bbcode_text = text
	list.add_child(l)
	if list.get_child_count() > 6:
		var c = list.get_children().front()
		list.remove_child(c)
		c.queue_free()
		
func _on_Timer_timeout():
	timer.start()
	
	if list.get_child_count() > 0:
		var c = list.get_children().front()
		list.remove_child(c)
		c.queue_free()
