extends Process

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) != 1:
		send_output('usage: status')
		return 1
	send_output("Queue: " + str(len(server.input_queue)) + " / " + str(server.queue_length))
	send_output("Disk: " + str(server.used_disk/1024.0) + "GB / " + str(server.disk/1024.0) + "GB")
	send_output("RAM: " + str(server.used_ram/1024.0) + "GB / " + str(server.ram/1024.0) + "GB")
	send_output("CPU: " + str(100 * server.used_cpu_cycles / server.cpu_cycles) + "%")
	return 0
