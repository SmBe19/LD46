extends Process

func usage():
	send_output('usage: pwd')

func help():
	send_output("Output the current working directory.\n")
	usage()
	
	
func run(args):
	send_output(cwd.full_path())
	return 0
