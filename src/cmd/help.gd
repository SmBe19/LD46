extends Process

func run(args):
	send_output("Resign lobster!")
	return 0

func help():
	send_output("Help helps")
	usage()
	
func usage():
	send_output("Usage: help")
