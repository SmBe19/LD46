extends Process

func usage():
	send_output('usage: iptables')

func help():
	send_output("Show iptables firewall configuration.\n")
	send_output("With iptables you can configure a server to reject certain request types or requests from a certain ip range.\n")
	send_output("If you want to prevent a request from entering your network you have to filter it at the ingress server (the server 'shoutr'). Once a request is in the network, it can not be dropped anymore. Please note however that rejecting a request at the ingress server will make the users unhappy (the same as if the request took too long to process).\n")
	usage()
	send_output("\nAlso see: set_iptables")

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 1:
		usage()
		return 1
	var node = self.fs_root.get_node("/etc/iptables")
	if node == null:
		send_output("No rules defined")
		return 0
	var blocked = 0
	for i in server.iptables_blocked:
		blocked += i
	send_output('Blocked ' + str(blocked) + ' requests in last 30s.')
	var is_first = true
	for route in node.children.keys():
		if route.begins_with('.'):
			continue
		if not is_first:
			send_output(" ")
		is_first = false
		send_output(route + ":")
		var routes = node.open(route).content
		send_output(routes)
	return 0
