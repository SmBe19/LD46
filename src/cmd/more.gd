extends Process

func usage():
	send_output('usage: more <file>')

func help():
	send_output("View text line-by-line. " +
	 "Press escape or q to exit before reaching the end of the file, "+
	 "or any other key to advance to the next line.\n")
	usage()
	send_output("\nAlso see: cat")


func run(args):
	if len(args) < 2:
		send_output('usage: more <file>')
		return 1
	if not output_process is Terminal:
		send_output("more: output not a tty")
		return 1
	output_process.cursor_x = -1
	output_process.cursor_y = -1
	var file = self.cwd.open(args[1])
	if file == null:
		send_output("more: "+args[1]+ ": no such file or directory")
		return 1
	var lines = file.content.split('\n')
	var visual_lines = []
	for x in lines:
		while len(x) > Terminal.WIDTH:
			visual_lines.append(x.left(Terminal.WIDTH-1) + ">")
			x = "..." + x.right(Terminal.WIDTH-1)
		visual_lines.append(x)
	var initial_scroll = Terminal.HEIGHT - 2
	for x in visual_lines:
		send_output(x)
		initial_scroll -= 1
		if initial_scroll <= 0 and output_process.current_line >= Terminal.HEIGHT-1:
			var key = yield(output_process, "key_pressed")
			if key == KEY_ESCAPE or key == ord('q'):
				return 0
	return 0
