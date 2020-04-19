extends Process


func usage():
	send_output('usage: echo [<string>...]')

func help():
	send_output("Display a string of text.\n")
	usage()
	
func run(args):
	var line = ""
	for i in range(1,len(args)):
		if i != 1:
			line += " "
		line += args[i]
	send_output(line)
	return 0
