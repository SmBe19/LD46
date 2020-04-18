extends Process

func usage():
	send_output('usage: man <page>')

func help():
	send_output("man is the system's manual pager. Each page argument given" +
	" to man is normally the name of a program, service or request. " + 
	"The manual page associated with each of these arguments is then found and displayed.")
	usage()

func run(args):
	if len(args) != 2:
		usage()
		return 1
	var process = spawn_subprocess(args[1])
	if process is Process:
		send_output('== ' + args[1] + " (Process) ==")
		process.help()
	if RequestHandler.request_types.has(args[1]):
		var request = RequestHandler.request_types[args[1]]
		send_output("== " + args[1] + " (Request) ==")
		send_output("Full name: " + request.human_name)
		send_output("This request can be split into the following subrequests: ")
		for r in request.requirements:
			send_output(" * " + r.type.full_name + " x" + str(r.count))
		
	return 0
