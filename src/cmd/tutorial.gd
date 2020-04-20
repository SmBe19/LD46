extends Process

func usage():
	send_output('usage: tutorial')

func help():
	send_output("Gives you hints on how to proceed.\n")
	usage()

func handle_tutorial(status):
	if not status.has('initial_welcome'):
		status['initial_welcome'] = true
		send_output("Welcome to Linux Simulator 2020.\n\nThis is a state of the art work simulator. Take on the role of a network engineer at shoutr.io, the latest and best social network (it's like twitter but for angry users).\n")
		send_output("Your job is to keep the whole datacenter alive. Unfortunately, the last guy destroyed all servers, so you will have to start from scratch.\n")
		return

func run(args):
	if len(args) < 1:
		usage()
		return 1
	var fs = Root.servers[0].fs_root
	var config = fs.open("/etc/tutorial", true)
	var status = {}
	for line in config.content.split("\n"):
		var parts = line.split("=", true)
		if len(parts) < 2:
			continue
		status[parts[0]] = parts[1]
	handle_tutorial(status)
	config.content = ""
	for key in status.keys():
		config.content += key + "=" + str(status[key])
	return 0
