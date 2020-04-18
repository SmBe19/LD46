extends Process

func run(args):
	send_output(cwd.full_path())
	return 0
