extends Node2D


var time = 0

export var value : float = 0

func _ready():
	$Label.text = self.name
	pass

func mix(a, b, x):
	return a+(b-a)*x

func _process(delta):
	time += delta
	$Pointer.rotation_degrees = mix(-145, -36, value)
	if value >= 0.99:
		$Pointer.rotation_degrees -= 5 * abs(sin(10*time))
	pass
