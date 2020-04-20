extends Process

func usage():
	send_output('usage: rm <file> [<file> ...]')

func help():
	send_output("Remove files\n")
	usage()
	send_output("\nAlso see: rmdir, mv, cp")

func run(args):
	if len(args) < 2:
		usage()
		return 1
	var failed = false
	for i in range(1, len(args)):
		filename = args[i]
		var file = self.cwd.get_node(filename)
		if file == null:
			send_output("rm: " + filename + ": no such file")
			failed = true
			continue
		if file.file_type('') != 'file':
			send_output("rm: " + filename + ": is not a file")
			failed = true
			continue
		file.parent.children.erase(file.name)
	if failed:
		return 1
	return 0
