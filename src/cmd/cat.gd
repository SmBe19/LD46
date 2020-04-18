extends Process

func run(args):
	if len(args) < 2:
		send_output('usage: cat <file>')
		return 1
	var res = ""
	for i in range(1, len(args)):
		var file = self.fs_open(args[i])
		if file == null:
			send_output("cat: "+args[1]+ ": no such file or directory")
			return 1
		res += file.content
	send_output(res)
	return 0
