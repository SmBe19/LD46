extends Process

func run(args):
	send_output("Resign lobster!")
	send_output(" ")
	send_output("Run 'man' for more informations")
	send_output("Run 'tutorial' for hints")
	return 0

func help():
	send_output("Help helps")
	usage()
	
func usage():
	send_output("Usage: help")
