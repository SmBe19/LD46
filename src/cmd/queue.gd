extends Process

func usage():
	send_output('usage: queue')

func help():
	send_output("Display unprocessed requests in the queue.\n")
	usage()
	send_output("\nAlso see: status")

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) != 1:
		usage()
		return 1
	for request in server.input_queue:
		send_output(request.type.human_name + " " + str(request.id))
	return 0
