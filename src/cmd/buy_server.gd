extends Process

func usage():
	send_output('usage: buy_server <server_name>')

func help():
	send_output("Buy and assign a name to a new server.\n")
	usage()
	send_output("\nAlso see: buy_connection, buy_upgrade")
	
func run(args):
	if len(args) != 2:
		usage()
		return 1
	var res = ask_money(Root.new_server_price())
	if res is GDScriptFunctionState:
		res = yield(res, 'completed')
	if not res:
		return 0
	var new_server = Root.add_new_server(args[1], Root.random_ip('10'))
	if new_server:
		send_output(new_server)
		return 1
	send_output('Successfully bought server')
	return 0
