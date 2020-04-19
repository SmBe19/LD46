extends Process

func average(values):
	var sum = 0
	for value in values:
		sum += value
	if len(values) > 0:
		sum /= len(values)
	return sum

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) != 1:
		send_output('usage: ps')
		return 1
	for service in server.installed_services:
		send_output(service.type.full_name + " " + str(100 * average(service.cycles_in_last_tick) / server.cpu_cycles) + "%")
	return 0
