extends Process

func run(args):
	if len(args) < 2:
		send_output('usage: cat <file>')
		return 1
	var file = self.cwd.open(args[1])
	if file == null:
		send_output("cat: no such file or directory")
		return 1
	send_output(file.content)
	return 0
