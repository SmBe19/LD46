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
	if not output_process is Terminal:
		send_output("more: output not a tty")
		return 1
	if len(args) == 1:
		var content = ""
		for line in input_queue:
			content += line + "\n"
		var res = page_output(content)
		if res is GDScriptFunctionState:
			return yield(res, 'completed')
		return res
	if len(args) < 2:
		send_output('usage: more <file>')
		return 1
	var file = self.cwd.open(args[1])
	if file == null:
		send_output("more: "+args[1]+ ": no such file or directory")
		return 1
	var res = page_output(file.content)
	if res is GDScriptFunctionState:
		return yield(res, 'completed')
	return res
