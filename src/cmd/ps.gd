extends Process

func usage():
	send_output('usage: ps')

func help():
	send_output("Show process information.\n")
	usage()

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 1:
		usage()
		return 1
	for service in server.installed_services:
		var running = "Running" if service.is_running() else "Stopped"
		send_output(service.type.full_name + " | " + running + " | " + str(service.queue_size) + " in service | " + str(100 * Root.average(service.cycles_in_last_tick) / server.cpu_cycles) + "%")
	return 0
