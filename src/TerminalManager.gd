extends MarginContainer


var terminal
var shell

func _ready():
	terminal = Terminal.new()
	shell = Sh.new(terminal)
	#for y in terminal.HEIGHT:
	#	for x in terminal.WIDTH:
	#		if (x+y)%2 == 1:
	#			terminal.set_char(x, y, str(y%10))
	shell.run([])
	

func _process(_delta):
	var text = ""
	for bline in terminal.buffer:
		var line = ""
		for c in bline:
			line += c
		line += "\n"
		text += line
	$Buffer.text = text

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.unicode != 0:
				terminal.emit_signal("key_pressed", event.unicode)
			else:
				terminal.emit_signal("key_pressed", event.scancode)
