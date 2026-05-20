extends Spatial
class_name TapIndicator

onready var _template = $template

var _holders :Dictionary = {} # {node:float}

func tap(pos :Vector3):
	var dup = _template.duplicate()
	dup.set_as_toplevel(true)
	dup.visible = true
	add_child(dup)
	dup.translation = pos
	_holders[dup] = 1.0
	
func _process(delta):
	if _holders.empty():
		return
		
	for node in _holders.keys():
		var scal = _holders[node]
		if scal < 0.05:
			_holders.erase(node)
			node.queue_free()
			return
			
		_holders[node] = lerp(scal, 0, 5 * delta)
		node.scale = Vector3.ONE * _holders[node]
