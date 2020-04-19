extends Process

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) != 1:
		send_output('usage: ddos')
		return 1
	var node = self.fs_root.get_node("/etc/ddos")
	if node == null:
		send_output("No rules defined")
		return 0
	for route in node.children.keys():
		if route.begins_with('.'):
			continue
		var rule = route + ".0.0.0/24: " if route != '*' else '*: '
		rule += "sample: " + node.open(route + "/sample_rate").content
		rule += "; check count: " + node.open(route + "/check_count").content
		rule += '\n'
		send_output(rule)
	return 0
