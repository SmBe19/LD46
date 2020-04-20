extends Process

func usage():
	send_output('usage: set_route <request_type> [<server> ...]')

func help():
	send_output("Create request forwarding rule.\nIf a request can not be handled locally (because there is no matching service or the service is currently overloaded) it will be forwarded to other servers according to the rules defined here. If no rule is defined, the request is returned to the local queue.\n")
	send_output("Please note that you can only forward packets if you have a connection between the two servers.\n")
	send_output("If you specify multiple servers, one of them is chosen at random. This allows you to balance the load onto multiple servers.\n")
	usage()
	send_output("\nAlso see: routes, buy_connection, ping, netstat")

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 2:
		usage()
		return 1
	if not RequestHandler.request_types.has(args[1]) and args[1] != '*':
		send_output('Invalid request type')
		return 1
	var route = ""
	for i in range(2, len(args)):
		var server = Root.resolve_ip(Root.resolve_name(args[i]))
		if not server:
			send_output('Could not resolve ' + args[i])
			return 1
		route += args[i] + "\n"
	server.fs_root.open('etc/requests/' + args[1], true).content = route
	return 0
