extends Process

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) != 2:
		send_output('usage: uninstall <service_name>')
		return 1
	var res = server.uninstall_service(args[1]):
	if res:
		send_output(res)
		return 1
	return 0
