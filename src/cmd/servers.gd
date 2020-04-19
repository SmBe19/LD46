extends Process

func run(args):
	if len(args) != 1:
		send_output('usage: servers')
		return 1
	for server in Root.servers:
		send_output(server.ip + ' ' + server.server_name)
	return 0
