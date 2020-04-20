extends Process

func usage():
	send_output('usage: touch <file> [file...]')

func help():
	send_output("Create empty files\n")
	usage()
	send_output("\nAlso see: ls, rm")

func run(args):
	if len(args) < 2:
		usage()
		return 1
	for i in range(1, len(args)):
		var file = self.cwd.open(args[i], true)
		if file == null:
			send_output("touch: " + args[i] + ": no such file or directory")
			return 1
	return 0
