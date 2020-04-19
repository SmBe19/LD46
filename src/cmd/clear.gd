extends Process

func usage():
	send_output('usage: clear')

func help():
	send_output("Clear the screen.")
	usage()
	
func run(args):
	if output_process is Terminal:
		output_process.clear_screen()
	return 0
