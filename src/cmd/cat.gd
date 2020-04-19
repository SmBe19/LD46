extends Process

func usage():
	send_output('usage: cat <file> [<file>...]')

func help():
	send_output("Concatenate and display files. Use with "+
		"a single file to show a file's contents.\n")
	usage()
	send_output("\nAlso see: ls, more")

func run(args):
	if len(args) < 2:
		usage()
		return 1
	var res = ""
	for i in range(1, len(args)):
		var file = self.cwd.open(args[i])
		if file == null:
			send_output("cat: "+args[1]+ ": no such file or directory")
			return 1
		res += file.content
	send_output(res)
	return 0
