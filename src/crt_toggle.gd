extends Button

var original_color

func _ready():
	original_color = $"../Terminal/Buffer".get('custom_colors/default_color')

func _toggled(active: bool) -> void:
	$"../CRT effect".visible = active
	if active:
		$"../Terminal/Buffer".set('custom_colors/default_color', original_color)
	else:
		$"../Terminal/Buffer".set('custom_colors/default_color', Color(0.8, 0.9, 0.8))
	pass
