extends Process

func help():
	send_output("Tells you the current timestamp (in game ticks).")
	usage()

func usage():
	send_output('usage: date')

func run(args):
	send_output("%s" % [Root.game_tick])
	return 0
