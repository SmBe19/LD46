extends Process

func run(args):
	Root.send_daily_report()
	return 0
