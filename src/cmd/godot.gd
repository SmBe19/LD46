extends Process

func usage():
	send_output('usage: godot')

func help():
	send_output("Godot game engine.\n")
	usage()

func run(args):
	send_output("No recursion allowed.")
	return 1
	
