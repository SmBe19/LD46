extends Process

func usage():
	send_output('usage: servers')

func help():
	send_output("List available servers.\n")
	usage()
	send_output("\nAlso see: buy_server")
	
func run(args):
	if len(args) != 1:
		usage()
		return 1
	for server in Root.servers:
		send_output(server.ip + ' ' + server.server_name)
	return 0
