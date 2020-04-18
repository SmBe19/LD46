extends Process

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) != 1:
		send_output('usage: queue')
		return 1
	for request in server.input_queue:
		send_output(request.type.human_name)
