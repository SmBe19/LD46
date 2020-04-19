extends Process

func usage():
	send_output('usage: uninstall <service_name>')

func help():
	send_output("Uninstalls a service to free system resources.\n")
	usage()
	send_output("\nAlso see: install")
	
func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 2:
		return 1
	var res = server.uninstall_service(args[1])
	if res:
		send_output(res)
		return 1
	return 0
