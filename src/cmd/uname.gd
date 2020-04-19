extends Process

func usage():
	send_output('usage: uname')

func help():
	send_output("Display information about the operating system\n")
	usage()
	send_output('\nAlso see: status')
	
func run(args):
	send_output("Lunix 1.0 - (c) 1991 Linyos Torovoltos")
	return 0
