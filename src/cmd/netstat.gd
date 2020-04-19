extends Process


func usage():
	send_output('usage: netstat')

func help():
	send_output("Display information about current network connections.\n")
	usage()
	send_output("\nAlso see: status")


func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) != 1:
		usage()
		return 1
	if not server.connections:
		send_output("No connections")
		return 0
	for con in server.connections.keys():
		var srv = Root.resolve_ip(con)
		send_output(srv.server_name + " " + srv.ip)
	return 0
