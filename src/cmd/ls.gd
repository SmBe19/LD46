extends Process

func run(args):
	var status = 0
	if len(args) == 1:
		var elements = self.cwd.children.keys()
		elements.sort()
		send_output_list(elements)
	else:
		for i in range(1, len(args)):
			var node = self.cwd.get_node(args[i])
			if node == null:
				send_output("ls: " + args[i] + ": file not found")
				status = 1
			else:
				if node.is_dir():
					send_output(args[i] + ":")
					var elements = node.children.keys()
					elements.sort()
					send_output_list(elements)
				else:
					send_output(" " + node.name)
	return status
