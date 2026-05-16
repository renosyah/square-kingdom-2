extends IndirectProjectile

onready var spatial = $Spatial

func _process(delta):
	spatial.rotate_z(45 * delta)
