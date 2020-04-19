extends Process

func usage():
	send_output('usage: routes')

func help():
	send_output("Display current routing table.\n")
	usage()
	send_output("\nAlso see: queue")


func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 1:
		usage()
		return 1
	var node = self.fs_root.get_node("/etc/requests")
	if node == null:
		send_output("No routes defined")
		return 0
	for route in node.children.keys():
		if route.begins_with('.'):
			continue
		send_output(route + ":")
		var routes = node.open(route).content
		send_output(routes)
	return 0
