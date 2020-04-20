extends MarginContainer


var terminal
var shell

func _ready():
	terminal = Terminal.new()
	shell = preload("res://src/cmd/sh.gd").new()
	shell.output_process = terminal
	#for y in terminal.HEIGHT:
	#	for x in terminal.WIDTH:
	#		if (x+y)%2 == 1:
	#			terminal.set_char(x, y, str(y%10))
	shell.run([])
	

func _process(_delta):
	if not Root.game_running:
		$Buffer.clear()
		$Buffer.add_text('\n\n')
		$Buffer.add_text('You lost!\n')
		$Buffer.add_text('The network was unable to cope with the requests.\n')
		$Buffer.add_text('You survived for ' + str(Root.game_tick / Root.TICK_PER_SECOND) + 's.\n')
		$Buffer.add_text('\n\n\n')
		$Buffer.add_text('Linux Simulator 2020\n\n\n')
		$Buffer.add_text('a game by actual programmers (with degrees!*):\n\n')
		$Buffer.add_text('M Signer\n')
		$Buffer.add_text('Fabian Lyck\n')
		$Buffer.add_text('Benjamin Schmid\n\n\n\n\n')
		$Buffer.add_text('* does not imply competence')
		return
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
