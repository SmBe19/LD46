extends Process

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 2:
		send_output('usage: set_route <request_type> [<server> ...]')
		return 1
	if not RequestHandler.request_types.has(args[1]):
		send_output('Invalid request type')
		return 1
	var route = ""
	for i in range(2, len(args)):
		var server = Root.resolve_ip(Root.resolve_name(args[i]))
		if not server:
			send_output('COuld not resolve ' + args[i])
			return 1
		route += args[i] + "\n"
	server.fs_root.open('etc/requests/' + args[1], true).content = route
	return 0
