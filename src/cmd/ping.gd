extends Process

func usage():
	send_output('usage: ping <server>')

func help():
	send_output("Test network connections. Server can be given as a host name or IP address.")
	send_output("Can only connect to servers that are directly connected.")
	send_output(" ")
	usage()
	send_output("\nAlso see: netstat")

func run(args):
	if len(args) < 2:
		usage()
		return 1
	if len(args[1].split('.')) != 4:
		if not Root.dns.has(args[1]):
			send_output('Could not resolve ' + args[1] + '.')
			return 1
	var ip = Root.resolve_name(args[1])
	send_output('PING ' + args[1] + ' (' + ip + ')')
	var success = not server or server.ip == ip or server.connections.has(ip)
	for i in 4:
		yield(Root.get_tree().create_timer(1), 'timeout')
		if success:
			var time = 1+randf()
			if server.ip != ip:
				time += Server.CONNECTION_DELAY - 1
			send_output('64 bytes from ' + ip + ' time=' + str(time))
		else:
			send_output('timeout')
	return 0
