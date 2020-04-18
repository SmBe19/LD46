extends Process


var lines = [""]
var line = 0
var col = 0
var scroll_start = 0

var insert : bool = false

func run(args):
	if not output_process is Terminal:
		send_output("vi: output not a tty")
		return 1
		
	output_process.clear_screen()

	while true:
		output_process.cursor_y = line - scroll_start
		output_process.cursor_x = col
		update_statusbar()
		var key = yield(output_process, "key_pressed")
		print(key)
		if insert:
			if key == KEY_ESCAPE:
				insert = false
				make_col_inbound()
			elif key >= KEY_SPACE && key <= KEY_ASCIITILDE:
				lines[line] = lines[line].insert(col, String(char(key)))
				col += 1
				update_line(line)
			elif key == KEY_ENTER:
				var tmp : String = lines[line]
				print(col)
				print(tmp.right(col))
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
		else:
			if key == KEY_ESCAPE:
				return
			if key == ord('i'):
				insert = true
			if key == ord('a'):
				insert = true
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

func make_col_inbound():
	col = min(col, max(0, len(lines[line])-1))

func update_line(line):
	output_process.set_line(line - scroll_start, lines[line])

func update_statusbar():
	var mode = "INSERT" if insert else "NORMAL"
	var pos = str(line+1) + ":" + str(col+1)
	output_process.set_line(output_process.HEIGHT - 1, mode + "  " + pos)
