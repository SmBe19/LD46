extends Process

func usage():
	send_output('usage: reset_log_cache')

func help():
	send_output("Resets the log cache on the server.\n")
	send_output("The log cache is used to prevent writing the same log message multiple times.\n")
	usage()

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 1:
		usage()
		return 1
	
	server.error_servers = []
	server.error_requests = []
	server.error_forwarding = []
	server.error_services = []
	server.error_iptables = []
	server.error_ram = []
	return 0
