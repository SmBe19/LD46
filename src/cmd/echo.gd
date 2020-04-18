extends Process

func run(args):
	var line = ""
	for i in range(1,len(args)):
		if i != 1:
			line += " "
		line += args[i]
	send_output(line)
	return 0
