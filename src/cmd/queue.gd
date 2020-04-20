extends Process

func usage():
	send_output('usage: queue')

func help():
	send_output("Display unprocessed requests in the queue.\n")
	send_output("If the queue is full, no new requests will be accepted from other servers or users. Users will become unhappy if they can not place their requests.\n")
	usage()
	send_output("\nAlso see: status, ps")

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 1:
		usage()
		return 1
	for request in server.input_queue:
		send_output(request.type.full_name + " " + str(request.id))
	for slice in server.incoming_requests:
		for request in slice:
			send_output(request.type.full_name + " " + str(request.id))
	return 0
