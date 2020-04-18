extends Process

func run(args):
	if len(args) != 2:
		send_output('usage: buy_server <server_name>')
		return 1
	var res = Root.add_new_server(args[1], Root.random_ip())
	if res:
		send_output(res)
		return 1
	return 0
