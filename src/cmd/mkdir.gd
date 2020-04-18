extends Process

func run(args):
	if len(args) < 2:
		send_output('usage: mkdir <dir>')
		return 1
	var error = self.fs_mkdir(args[1])
	if error != "":
		send_output("mkdir: " + error)
		return 1
	return 0
	
