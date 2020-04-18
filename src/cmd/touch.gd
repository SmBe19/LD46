extends Process

func run(args):
	if len(args) < 2:
		send_output('usage: touch <file>')
		return
	var file = self.cwd.open(args[1], true)
	if file == null:
		send_output("touch: no such file or directory")
