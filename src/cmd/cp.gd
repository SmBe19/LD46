extends Process

func usage():
	send_output('usage: cp <file> <file>')

func help():
	send_output("Copy files\n")
	usage()
	send_output("\nAlso see: mv, rm")

func run(args):
	if len(args) < 3:
		usage()
		return 1
	var infile = self.cwd.open(args[1])
	if infile == null:
		send_output("cp: " + args[1] + ": no such file")
		return 1
	if infile.file_type('') != 'file':
		send_output("cp: " + args[1] + ": is not a file")
		return 1
	var outfile = self.cwd.open(args[2], true)
	if outfile.file_type('') != 'file':
		send_output("cp: " + args[2] + ": is not a file")
		return 1
	outfile.content = infile.content
	return 0
