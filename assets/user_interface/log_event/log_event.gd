extends MarginContainer

var current_player :PlayerData

onready var list = $VBoxContainer
onready var temp = $temp
onready var timer = $Timer

func _ready():
	timer.start()

func add_log_damage(squad :BaseSquad, amount :int):
	var from :BaseSquad = get_node_or_null(squad.attacked_by)
	if not from:
		return
		
	if current_player.player_id in [from.player_id, squad.player_id]:
		var arr = [squad.color.to_html(),squad.unit_name,from.color.to_html(),from.unit_name, amount]
		add_log("[DMG] [color=#%s]%s[/color] struck by [color=#%s]%s[/color] for [color=red]%s[/color] damage" % arr)
	
func add_log_member_lost(squad :BaseSquad, member :SquadMember):
	var from :BaseSquad = get_node_or_null(member.attacked_by)
	if not from:
		return
		
	if current_player.player_id in [from.player_id, squad.player_id]:
		var arr = [squad.color.to_html(),squad.unit_name,from.color.to_html(),from.unit_name]
		add_log("[LOSS] [color=#%s]%s[/color] lost 1 men from [color=#%s]%s[/color]" % arr)
	
func add_log_squad_dead(squad :BaseSquad):
	var from :BaseSquad = get_node_or_null(squad.attacked_by)
	if not from:
		return
		
	if current_player.player_id in [from.player_id, squad.player_id]:
		var arr = [squad.color.to_html(),squad.unit_name,from.color.to_html(),from.unit_name]
		add_log("[DESTROYED] [color=#%s]%s[/color] Destroyed by [color=#%s]%s[/color]" % arr)
		
func add_log_squad_add_modifier(squad :BaseSquad, type :int, value:float, is_buff :bool):
	var type_label = ""
	match type:
		squad.modifier_melee_speed:
			type_label = "Melee Speed"
		squad.modifier_range_speed:
			type_label = "Fire Rate"
		squad.modifier_move_speed:
			type_label = "Movement"
		squad.modifier_damage_receive:
			type_label = "Resistance"
		squad.modifier_melee_damage:
			type_label = "Melee Damage"
		squad.modifier_range_damage:
			type_label = "Range Damage"
	var v = "%s%s" % [(value * 100),"%"] 
	if is_buff:
		var arr = [squad.color.to_html(),squad.unit_name,type_label,Color.green,v]
		add_log("[BUFF] [color=#%s]%s[/color] %s Improve By [color=#%s]%s[/color]" % arr)
	else:
		var arr = [squad.color.to_html(),squad.unit_name,type_label,Color.red,v]
		add_log("[NERF] [color=#%s]%s[/color] %s Reduce By [color=#%s]%s[/color]" % arr)
	
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
