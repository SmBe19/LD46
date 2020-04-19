extends Process

func usage():
	send_output('usage: vi [file]')

func help():
	send_output("vi is the system's file editor. It implements a subset of " +
	"the original UNIX vi functionality. \n")
	usage()

var lines : PoolStringArray = PoolStringArray([""])

var cursor_y = 0
var cursor_x = 0
var scroll_y = 0
var scroll_x = 0

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
			output_process.cursor_y = cursor_y - scroll_y
			output_process.cursor_x = cursor_x - scroll_x
		
		update_statusbar()
		var key = yield(output_process, "key_pressed")
		match mode:
			INSERT:
				match key:
					KEY_ESCAPE:
						mode = NORMAL
						make_col_inbound()
					KEY_ENTER:
						var tmp : String = lines[cursor_y]
						lines.insert(cursor_y+1, tmp.right(cursor_x))
						lines[cursor_y] = tmp.left(cursor_x)
						for i in range(cursor_y, len(lines)):
							update_line(i)
						cursor_y += 1
						cursor_x = 0
						update_scroll_x()
						update_scroll_y()
					KEY_BACKSPACE:
						if cursor_x > 0:
							cursor_x -= 1
							update_scroll_x()
							# yay buggy implementation
							var tmp = lines[cursor_y]
							tmp.erase(cursor_x, 1)
							lines[cursor_y] = tmp
							update_line(cursor_y)
						elif cursor_y > 0: # delete newline
							cursor_y -= 1
							cursor_x = len(lines[cursor_y])
							var joined = lines[cursor_y] + lines[cursor_y+1]
							lines[cursor_y] = joined
							lines.remove(cursor_y+1)
							for i in range(cursor_y, len(lines)+1):
								update_line(i)
							update_scroll_x()
							update_scroll_y()
					_:if key >= KEY_SPACE && key <= KEY_ASCIITILDE:
						lines[cursor_y] = lines[cursor_y].insert(cursor_x, String(char(key)))
						cursor_x += 1
						update_scroll_x()
						update_line(cursor_y)
			NORMAL:
				match key:
					# insert
					ord('i'):
						mode = INSERT
					ord('a'):
						mode = INSERT
						cursor_x += 1
						update_scroll_x()
					ord('I'):
						mode = INSERT
						cursor_x = 0
						update_scroll_x()
					ord('A'):
						mode = INSERT
						cursor_x = len(lines[cursor_y])
						update_scroll_x()
					ord('C'):
						mode = INSERT
						lines[cursor_y] = ""
						cursor_x = 0
						update_scroll_x()
						update_line(cursor_y)
						
					ord('h'), KEY_LEFT:
						if cursor_x > 0:
							cursor_x -= 1
							update_scroll_x()
					ord('l'), KEY_RIGHT:
						if cursor_x + 1 < len(lines[cursor_y]):
							cursor_x += 1
							update_scroll_x()
					ord('j'), KEY_DOWN:
						if cursor_y + 1 < len(lines):
							cursor_y += 1
							make_col_inbound()
							update_scroll_y()
					ord('k'), KEY_UP:
						if cursor_y > 0:
							cursor_y -= 1
							make_col_inbound()
							update_scroll_y()
					ord('^'), ord('0'):
						cursor_x = 0
						update_scroll_x()
					ord('$'):
						cursor_x = len(lines[cursor_y])-1
						update_scroll_x()
						
					ord(':'):
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
							output_process.clear_screen()
							return 0
						cmdline = ""
						mode = NORMAL
					_:
						if key >= KEY_SPACE && key <= KEY_ASCIITILDE:
							cmdline += char(key)
	output_process.clear_screen()
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
	cursor_x = min(cursor_x, max(0, len(lines[cursor_y])-1))
	update_scroll_x()

func update_scroll_x():
	var updated = false
	if cursor_x < scroll_x:
		scroll_x = cursor_x
		updated = true
	if cursor_x >= scroll_x + Terminal.WIDTH-1:
		scroll_x = cursor_x - Terminal.WIDTH + 2
		updated = true
	if updated:
		for i in range(scroll_y, scroll_y + Terminal.HEIGHT-1):
			update_line(i)

func update_scroll_y():
	var updated = false
	if cursor_y < scroll_y:
		scroll_y = cursor_y
		updated = true
	if cursor_y >= scroll_y + Terminal.HEIGHT-1:
		scroll_y = cursor_y - Terminal.HEIGHT + 2
		updated = true
	if updated:
		for i in range(scroll_y, scroll_y + Terminal.HEIGHT-1):
			update_line(i)

func update_line(l):
	if l < scroll_y || l >= scroll_y + Terminal.HEIGHT-1:
		return
	var line
	if l < 0 || l >= len(lines):
		line = ""
	else:
		line = lines[l]
	line = line.substr(scroll_x, Terminal.WIDTH)
	output_process.set_line(l - scroll_y, line)

func update_statusbar():
	var statusbar
	if mode == COMMAND:
		statusbar = ":" + cmdline
	else:
		var pos = str(cursor_y+1) + ":" + str(cursor_x+1)
		statusbar = ("NORMAL" if mode == NORMAL else "INSERT") + "  " + pos
	
	output_process.set_line(output_process.HEIGHT - 1, statusbar)
