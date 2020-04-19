extends Process

func usage():
	send_output('usage: status')

func help():
	send_output("Display information about current system resource usage.\n")
	usage()
	send_output('\nAlso see: queue, uname')

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 1:
		usage()
		return 1
	send_output("Queue: " + str(min(len(server.input_queue), server.queue_length)) + " / " + str(server.queue_length))
	send_output("Disk: " + str(server.used_disk/1024.0) + "GB / " + str(server.disk/1024.0) + "GB")
	send_output("RAM: " + str(server.used_ram/1024.0) + "GB / " + str(server.ram/1024.0) + "GB")
	send_output("CPU (" + str(server.cpu_cycles) + " MHz): " + str(100 * Root.average(server.used_cpu_cycles) / server.cpu_cycles) + "%")
	return 0
