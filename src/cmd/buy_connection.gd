extends Process

func usage():
	send_output('usage: buy_connection <server1> <server2>')

func help():
	send_output("Buy connections for request routing between servers.\n")
	usage()
	send_output("\nAlso see: buy_server, /etc/requests/")
	
func run(args):
	if len(args) != 3:
		usage()
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
	var res = ask_money(Root.new_connection_price(srv1, srv2))
	if res is GDScriptFunctionState:
		res = yield(res, 'completed')
	if not res:
		return 0
	var new_con = Root.connect_servers(srv1, srv2)
	if new_con:
		send_output(new_con)
		return 1
	send_output('Successfully bought connection')
	return 0
