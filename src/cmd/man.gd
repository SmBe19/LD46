extends Process

func usage():
	send_output('usage: man <page>')
	send_output("Use `man list` to list all possible services and requests.")
	send_output("Press tab to list all possible programs.")

func help():
	send_output("man is the system's manual pager. Each page argument given" +
	" to man is normally the name of a program, service or request. " + 
	"The manual page associated with each of these arguments is then found and displayed.\n")
	usage()

func run(args):
	if len(args) < 2:
		usage()
		return 1
	var more = null
	if output_process is Terminal:
		more = spawn_subprocess('more')
		more.output_process = output_process
		output_process = more
	var foundSomething = false
	var process = spawn_subprocess(args[1])
	if process is Process:
		send_output('== ' + args[1] + " (Process) ==\n")
		process.help()
		foundSomething = true
	if RequestHandler.request_types.has(args[1]):
		var request = RequestHandler.request_types[args[1]]
		send_output("== " + args[1] + " (Request) ==\n")
		send_output("Full name: " + request.human_name)
		if request.requirements:
			send_output(' ')
			send_output("This request can be split into the following subrequests: ")
			for r in request.requirements:
				send_output(" * " + r.type.full_name + " x" + str(r.count))
		send_output(' ')
		send_output("This request can be processed by these services: ")
		for p in ServiceHandler.service_types.values():
			if request in p.inputs.keys():
				send_output(" * " + p.full_name)
		foundSomething = true
	
	if ServiceHandler.service_types.has(args[1]):
		var service = ServiceHandler.service_types[args[1]]
		send_output("== " + args[1] + " (Service) ==\n")
		send_output("Full name: " + service.human_name)
		send_output(' ')
		send_output("Disk Space: " + str(service.disk/1024.0) + " GB")
		send_output("RAM: " + str(service.ram/1024.0) + " GB")
		send_output("CPU: " + str(service.cpu) + " M Cycles")
		if service.inputs.keys():
			send_output(' ')
			send_output("This service will process the following requests: ")
			for type in service.inputs.keys():
				send_output(" * " + type.full_name + " x" + str(service.inputs[type]))
		if args[1] == 'ddos':
			send_output(' ')
			send_output('This service can process all requests.')
		var requests = {}
		for type in service.inputs.keys():
			for r in type.requirements:
				if not requests.has(r.type.full_name):
					requests[r.type.full_name] = 0
				requests[r.type.full_name] += 1
		if requests:
			send_output(' ')
			send_output("This service will produce the following subrequests: ")
			for type in requests:
				send_output(" * " + type + " x" + str(requests[type]))
		if args[1] == 'ddos':
			send_output(' ')
			send_output('This service will return the same request or a ddos request if detected.')
		foundSomething = true
	if args[1] == "list":
		
		send_output("== Requests ==\n")
		for r in RequestHandler.request_types.values():
			send_output(" * " + r.full_name)
		send_output("\n\n== Services ==\n")
		for p in ServiceHandler.service_types.values():
			send_output(" * " + p.full_name)
		foundSomething = true
	if not foundSomething:
		if more:
			output_process = more.output_process
		send_output("No program, service or request by that name found. ")
		send_output("Use `man list` to list all possible services and requests.")
		send_output("Press tab to list all possible programs.")
		return 1
	if more:
		var res = more.run(['more'])
		if res is GDScriptFunctionState:
			res = yield(res, "completed")
	return 0
