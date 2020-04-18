extends MarginContainer


var terminal
var shell

func _ready():
	terminal = Terminal.new()
	shell = Sh.new()
	shell.output_process = terminal
	#for y in terminal.HEIGHT:
	#	for x in terminal.WIDTH:
	#		if (x+y)%2 == 1:
	#			terminal.set_char(x, y, str(y%10))
	shell.run([])
	

func _process(_delta):
	$Buffer.clear()
	for i in len(terminal.buffer):
		var bline = terminal.buffer[i]
		var line = ""
		for j in len(bline):
			if i == terminal.cursor_y and j == terminal.cursor_x:
				$Buffer.add_text(line)
				$Buffer.push_underline()
				$Buffer.add_text(bline[j])
				$Buffer.pop()
				line = ""
			else:
				line += bline[j]
		$Buffer.add_text(line)
		$Buffer.newline()

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.unicode != 0:
				terminal.emit_signal("key_pressed", event.unicode)
			else:
				terminal.emit_signal("key_pressed", event.scancode)
