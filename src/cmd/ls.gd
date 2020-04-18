extends Process

func run(args):
	var status = 0
	if len(args) == 1:
		for key in self.cwd.children.keys():
			send_output(" " + key)
	else:
		for i in range(1, len(args)):
			send_output(args[i] + ":")
			var node = self.cwd.get_node(args[i])
			if node == null:
				send_output("ls: " + args[i] + ": file not found")
				status = 1
			else:
				if node.is_dir():
					for key in node.children.keys():
						send_output(" " + key)
				else:
					send_output(" " + node.name)
	return status
