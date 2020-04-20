extends Process

func usage():
	send_output('usage: ddos')

func help():
	send_output("Show ddos configuration.\n")
	send_output("Some users flood your network with fake requests. You don't receive any money from these requests and the only goal is to overwhelm your system.")
	send_output("You can use DDoS detection to scan a request. If the request is deemed a fake request, its request type is changed to 'fake'. Note however, that some small part of the real requests will also be classified as fake (see set_ddos).\n")
	send_output("The fake requests can be sent to the blackhole service, which just drops them, or to the analyzer service, which gives you the corresponding ip addresses. You can then use these with iptables and in the ddos configuration to filter the traffic.\n")
	usage()
	send_output("\nAlso see: set_ddos, queue")

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 1:
		usage()
		return 1
	var node = self.fs_root.get_node("/etc/ddos")
	if node == null:
		send_output("No rules defined")
		return 0
	if server.has_ddos_installed:
		send_output("DDoS Service installed")
	else:
		send_output("DDoS Service not installed")
	var checked = 0
	for i in server.ddos_checked:
		checked += i
	var blocked = 0
	for i in server.ddos_detected:
		blocked += i
	send_output('Checked ' + str(checked) + ' requests in last 30s.')
	send_output('Detected ' + str(blocked) + ' fake requests in last 30s.')
	for route in node.children.keys():
		if route.begins_with('.'):
			continue
		var rule = route + ".0.0.0/24: " if route != '*' else '*: '
		rule += "sample: " + node.open(route + "/sample_rate").content
		rule += "%; check count: " + node.open(route + "/check_count").content
		rule += '\n'
		send_output(rule)
	return 0
