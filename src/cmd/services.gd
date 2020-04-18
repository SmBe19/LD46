extends Process

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) != 1:
		send_output('usage: services')
		return 1
	for service in server.installed_services:
		send_output(service.type.full_name)
	return 0
