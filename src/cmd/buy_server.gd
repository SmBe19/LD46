extends Process

func run(args):
	if len(args) != 2:
		send_output('usage: buy_server <server_name>')
		return 1
	if Root.add_new_server(args[1], Root.random_ip()):
		return 0
	return 1
