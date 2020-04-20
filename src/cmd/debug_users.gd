extends Process

func run(args):
	for i in 20:
		UserHandler.generate_user()
	return 0
