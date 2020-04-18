extends Process


var lines : PoolStringArray = PoolStringArray([""])
var line = 0
var col = 0
var scroll_start = 0

enum {
	NORMAL,
	INSERT,
	COMMAND
}

var mode  = NORMAL
var cmdline = ""

var current_file = ""

func run(args):
	output_process.clear_screen()
	
	if len(args) > 1:
		current_file = args[1]
		load_file(current_file)
	if not output_process is Terminal:
		send_output("vi: output not a tty")
		return 1

	while true:
		if mode == COMMAND:
			output_process.cursor_y = Terminal.HEIGHT-1
			output_process.cursor_x = 1+len(cmdline)
		else:
			output_process.cursor_y = line - scroll_start
			output_process.cursor_x = col
		
		update_statusbar()
		var key = yield(output_process, "key_pressed")
		match mode:
			INSERT:
				if key == KEY_ESCAPE:
					mode = NORMAL
					make_col_inbound()
				elif key >= KEY_SPACE && key <= KEY_ASCIITILDE:
					lines[line] = lines[line].insert(col, String(char(key)))
					col += 1
					update_line(line)
				elif key == KEY_ENTER:
					var tmp : String = lines[line]
					lines.insert(line+1, tmp.right(col))
					lines[line] = tmp.left(col)
					for i in range(line, len(lines)):
						update_line(i)
					line += 1
					col = 0
				elif key == KEY_BACKSPACE:
					if col > 0:
						col -= 1
						# yay buggy implementation
						var tmp = lines[line]
						tmp.erase(col, 1)
						lines[line] = tmp
						update_line(line)
			NORMAL:
				if key == KEY_ESCAPE:
					return 0
				if key == ord('i'):
					mode = INSERT
				if key == ord('a'):
					mode = INSERT
					col += 1
				
				if key == ord('h'):
					if col > 0:
						col -= 1
				if key == ord('l'):
					if col + 1 < len(lines[line]):
						col += 1
				if key == ord('j'):
					if line + 1 < len(lines):
						line += 1
						make_col_inbound()
				if key == ord('k'):
					if line > 0:
						line -= 1
						make_col_inbound()
				if key == ord('$'):
					col = len(lines[line])-1
				if key == ord(':'):
					mode = COMMAND
			COMMAND:
				match key:
					KEY_ESCAPE:
						cmdline = ""
						mode = NORMAL
					KEY_BACKSPACE:
						cmdline.erase(len(cmdline)-1, 1)
					KEY_ENTER:
						if run_cmdline():
							return 0
						cmdline = ""
						mode = NORMAL
					_:
						if key >= KEY_SPACE && key <= KEY_ASCIITILDE:
							cmdline += char(key)
	return 0

func load_file(fname):
	var file = self.cwd.open(fname)
	if file == null:
		return
	lines = PoolStringArray(file.content.split("\n"))
	if len(lines) == 0:
		lines = PoolStringArray([""])
	for i in len(lines):
		update_line(i)

func write_file(fname):
	var file = self.cwd.open(fname, true)
	if file == null:
		return
	file.content = lines.join('\n')

func run_cmdline() -> bool:
	var cmd = cmdline.split(' ', false)
	if len(cmd) == 0:
		return false
	if "quit".begins_with(cmd[0]):
		return true
	if "write".begins_with(cmd[0]):
		if len(cmd) > 1:
			write_file(cmd[1])
		else:
			if current_file != "":
				write_file(current_file)
	return false

func make_col_inbound():
	col = min(col, max(0, len(lines[line])-1))

func update_line(line):
	output_process.set_line(line - scroll_start, lines[line])

func update_statusbar():
	var statusbar
	if mode == COMMAND:
		statusbar = ":" + cmdline
	else:
		var pos = str(line+1) + ":" + str(col+1)
		statusbar = ("NORMAL" if mode == NORMAL else "INSERT") + "  " + pos
	
	output_process.set_line(output_process.HEIGHT - 1, statusbar)
