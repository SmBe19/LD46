extends Button

var original_color

func _ready():
	original_color = $"../Terminal/Buffer".get('custom_colors/default_color')

func _toggled(active: bool) -> void:
	$"../CRT effect".visible = active
	$"../Background_On".visible = active
	$"../Background_Off".visible = not active
