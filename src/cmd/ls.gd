extends Process

func list_pretty(elements):
	var keys = elements.keys()
	keys.sort()
	send_output("Created | Accessed | Type | Name")
	send_output("--------------------------------")
	for el in keys:
		if el == '.' or el == '..':
			continue
		if el.ends_with('/.') or el.ends_with('/..'):
			continue
		if elements[el] is FSFile:
			send_output("   %4d |     %4d | file | %s" % 
			[elements[el].created, elements[el].accessed, el])
		if elements[el]  is FSDir:
			send_output("   %4d |     %4d |  dir | %s" % 
			[elements[el].created, elements[el].accessed, el])

func list_basic(elements):
	var keys = elements.keys()
	keys.sort()
	send_output_list(keys)
	
func usage():
	send_output('usage: ls [-l] [<file1> <file2> ...]')

func help():
	send_output("Lists files and directory contents (the current working directory by default).")
	send_output("-l Show a detailed list with creation and last access time.")
	send_output(" ")
	usage()
	send_output("\nAlso see: cat")
	
	
func run(args):
	var all_elements = {}
	var nargs = len(args)
	var pretty = false
	for i in range(1, nargs):
		if args[i][0] == '-':
			if args[i] == '-l':
				pretty = true
			continue
		var node = self.cwd.get_node(args[i])
		if node == null:
			send_output("ls: " + args[i] + ": file not found")
			return 1
		else:
			if node.is_dir():
				var elements = node.children.duplicate()
				var dirname = args[i]
				if dirname.ends_with('/'):
					dirname = dirname.left(len(dirname)-1)
				for el in elements:
					all_elements[dirname + '/' + el] = elements[el]
			else:
				all_elements[node.name] = node
	if len(all_elements) == 0:
		for el in self.cwd.children:
			all_elements[el] = self.cwd.children[el]
	if pretty:
		list_pretty(all_elements)
	else:
		list_basic(all_elements)
	return 0
