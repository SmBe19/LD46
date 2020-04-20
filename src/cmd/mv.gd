extends Process

func usage():
	send_output('usage: mv <file> <file>')

func help():
	send_output("Move files\n")
	usage()
	send_output("\nAlso see: ls, cp, rm")

func run(args):
	if len(args) < 3:
		usage()
		return 1
	var infile = self.cwd.open(args[1])
	if infile == null:
		send_output("mv: " + args[1] + ": no such file")
		return 1
	if infile.file_type('') != 'file':
		send_output("mv: " + args[1] + ": is not a file")
		return 1
	var outfile = self.cwd.open(args[2], true)
	if outfile.file_type('') != 'file':
		send_output("mv: " + args[2] + ": is not a file")
		return 1
	outfile.content = infile.content
	infile.parent.children.erase(infile.name)
	return 0
