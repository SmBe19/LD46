extends MarginContainer

signal key_pressed(key)

var Terminal = preload("res://src/terminal.gd")
var terminal

func _ready():
	terminal = Terminal.new()
	for y in terminal.HEIGHT:
		for x in terminal.WIDTH:
			if (x+y)%2 == 1:
				terminal.set_char(x, y, str(y%10))

func _process(_delta):
	var text = ""
	for bline in terminal.buffer:
		var line = ""
		for c in bline:
			line += c
		line += "\n"
		text += line
	$Buffer.text = text

func _unhandled_key_input(event):
	if event.pressed:
		emit_signal("key_pressed", event.scancode)
