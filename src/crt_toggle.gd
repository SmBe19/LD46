extends Button


func _ready():
	pass # Replace with function body.

func _toggled(active: bool) -> void:
	$"../CRT effect".visible = active
	pass
