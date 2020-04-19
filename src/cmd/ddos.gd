extends Process

func usage():
	send_output('usage: ddos')

func help():
	send_output("Show ddos configuration.\n")
	usage()
	send_output("\nAlso see: set_ddos")

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
		send_output("DDOS Service installed")
	else:
		send_output("DDOS Service not installed")
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
