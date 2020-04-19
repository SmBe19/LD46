extends Process

func usage():
	send_output('usage: mkdir <directory> [<directory>...]')

func help():
	send_output("Create directories if they do not already exist ")
	usage()
	send_output("\nAlso see: touch")

func run(args):
	if len(args) < 2:
		usage()
		return 1
	for i in range(1, len(args)):
		var error = self.cwd.mkdir(args[i])
		if error != "":
			send_output("mkdir: " + error)
			return 1
	return 0
	
