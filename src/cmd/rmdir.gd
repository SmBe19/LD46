extends Process

func usage():
	send_output('usage: rmdir <dir> [<dir> ...]')

func help():
	send_output("Remove directories\n")
	usage()
	send_output("\nAlso see: ls, mkdir, rm")

func run(args):
	if len(args) < 2:
		usage()
		return 1
	var failed = false
	for i in range(1, len(args)):
		filename = args[i]
		var file = self.cwd.get_node(filename)
		if file == null:
			send_output("rmdir: " + filename + ": no such directory")
			failed = true
			continue
		if file.file_type('') != 'dir':
			send_output("rmdir: " + filename + ": is not a directory")
			failed = true
			continue
		if len(file.children) > 2:
			send_output("rmdir: " + filename + ": is not empty")
			failed = true
			continue
		file.parent.children.erase(file.name)
	if failed:
		return 1
	return 0
