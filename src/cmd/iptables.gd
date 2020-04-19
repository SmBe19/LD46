extends Process

func usage():
	send_output('usage: iptables')

func help():
	send_output("Show iptables firewall configuration.\n")
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
	for route in node.children.keys():
		if route.begins_with('.'):
			continue
		send_output(route + ":")
		var routes = node.open(route).content
		send_output(routes)
	return 0
