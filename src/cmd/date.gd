extends Process

func help():
	send_output("Tells you the current timestamp (in game ticks).")
	usage()

func usage():
	send_output('usage: date')

func run(args):
	send_output("Day %s, %s s (%s ticks since epoch)" % [int(Root.game_tick/Root.DAY_LENGTH), int((Root.game_tick % Root.DAY_LENGTH)/Root.TICK_PER_SECOND), Root.game_tick])
	return 0
