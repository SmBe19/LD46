extends Process

func help():
	send_output("Installs a service on this server. Make sure you have enough space available.")
	send_output("Use man <service_name> to find out more about specific services.\n")
	usage()
	send_output("\nAlso see: uninstall, ps")

func usage():
	send_output('usage: install <service_name>')

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 2:
		usage()
		return 1
	var res = server.install_service(args[1])
	if res:
		send_output(res)
		return 1
	return 0
