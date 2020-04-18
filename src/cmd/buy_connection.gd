extends Process

func run(args):
	if len(args) != 3:
		send_output('usage: buy_connection <server1> <server2>')
		return 1
	var srv1 = Root.resolve_ip(Root.resolve_name(args[1]))
	var srv2 = Root.resolve_ip(Root.resolve_name(args[2]))
	if not srv1:
		send_output("Server " + args[1] + " not found")
		return 1
	if not srv2:
		send_output("Server " + args[2] + " not found")
		return 1
	if srv1 == srv2:
		send_output("Servers can not be the same")
		return 1
	Root.connect_servers(srv1, srv2)
	return 0
