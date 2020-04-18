extends Process

func run(args):
	if output_process is Terminal:
		output_process.clear_screen()
	return 0
