extends Process

func usage():
	send_output('usage: ps')

func help():
	send_output("Show process information.\n")
	send_output("The shown percentage shows how many CPU cycles the process used on average in the last few time units.\n")
	send_output("If a service does not run even though it has enough requests it might not have enough RAM.\n")
	send_output("A service can only start once per time unit ('tick'), thus if a request can be processed in less than one time unit, the CPU will not be fully used even though there are enough requests.\nTo prevent this, a service can be installed multiple times.\n")
	usage()
	send_output("\nAlso see: status, queue")

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
