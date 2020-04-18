extends Process

func run(args):
	if len(args) < 2:
		send_output('usage: touch <file> [file...]')
		return
	for i in range(1, len(args)):
		var file = self.cwd.open(args[i], true)
		if file == null:
			send_output("touch: " + args[i] + ": no such file or directory")
