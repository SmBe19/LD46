extends Process

func usage():
	send_output('usage: which <command>')

func help():
	send_output("Find the file executed for a command\n")
	usage()
	
func run(args):
	if len(args) < 2:
		send_output('usage: which <command>')
		return 1
	var subprocess = spawn_subprocess(args[1])
	if subprocess is Process:
		send_output('/bin/' + args[1])
		return 0
	if server:
		for service in server.installed_services:
			if service.type.service_name == args[1]:
				send_output('/usr/bin/' + args[1])
				return 0
	send_output(args[1] + ' not found')
	return 1
