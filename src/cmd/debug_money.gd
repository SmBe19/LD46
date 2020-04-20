extends Process

func run(args):
	Root.money += 1e6
	Root.money_log.append("+$" + str(1e6) + ": Cheating")
	return 0
