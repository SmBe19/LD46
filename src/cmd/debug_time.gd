extends Process

func run(args):
	if len(args) < 2:
		send_output("debug_time <new_time>")
		return 1
	Root.game_tick = int(args[1])
	return 0
