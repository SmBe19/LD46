extends Process

func usage():
	send_output('usage: tutorial [basic|finished]')

func help():
	send_output("Gives you hints on how to proceed.")
	send_output("You can fast forward to later tutorial points:")
	send_output("- basic: after you bought the second server and configured it.")
	send_output("- finished: after you setup ddos protection\n")
	send_output("After you finished the tutorial, this command will analyze the situation and try to give useful hints.\n")
	usage()

func has_service(server, service_name):
	for service in server.installed_services:
		if service.type.service_name == service_name:
			return true
	return false

func has_request(server, request_name):
	for request in server.input_queue:
		if request.type.request_name == request_name:
			return true
	return false

func is_forwarded(source, request_type, destination):
	var file = source.fs_root.open('etc/requests/' + request_type)
	if not file:
		return false
	return file.content.begins_with(destination.server_name) or file.content.begins_with(destination.ip)

func initial_welcome(status):
	if status.has('initial_welcome'):
		return false
	status['initial_welcome'] = true
	send_output("Welcome to Linux Simulator 2020.\n\nThis is a state of the art work simulator. Take on the role of a network engineer at shoutr.io, the latest and best social network (it's like twitter but for angry people).")
	send_output("Your job is to keep the whole datacenter alive. Unfortunately, the last guy destroyed all servers, so you will have to start from scratch.")
	send_output("Explore the system and get to know the different parts. The command 'man' is a good place to start.")
	send_output("If you are ready to continue, type 'tutorial' again.")
	return true

func check_queue(status):
	if status.has('check_queue'):
		return false
	status['check_queue'] = true
	send_output("A good first step would be to check the queue of our server.")
	send_output("The queue contains requests that should be processed.")
	send_output(" ")
	send_output("Type 'queue' to see the requests.")
	send_output(" ")
	send_output("You can see the name of the request type and a unique identifier of the request.")
	send_output("With man you can get more information about a certain request type (e.g. 'man compute').")
	send_output(" ")
	send_output("Hint: in many places you can automatically complete what you are typing by pressing TAB.")
	return true

func install_initial_services(status):
	if status.has('install_initial_services'):
		return false
	if has_service(Root.servers[0], 'compute') and has_service(Root.servers[0], 'database'):
		status['install_initial_services'] = true
		return false
	send_output("You will now need to install services to handle the requests. At the moment there are only 'compute' and 'sql' requests.")
	send_output("Install services to handle these requests (using the command 'install').")
	if status.has('install_initial_services_should_show_hint'):
		send_output("Hint: 'install compute' and 'install database'")
	status['install_initial_services_should_show_hint'] = true
	return true

func money_intro(status):
	if status.has('money_intro'):
		return false
	if len(Root.money_log) < 3:
		send_output("Please try again later. You need to complete at least 2 requests.")
		return true
	status['money_intro'] = true
	send_output("You can now handle the basic requests. When you fulfill a request, you get money. The faster you process a request, the more money you will get.")
	send_output(" ")
	send_output("Type 'bitcoind' to see your current balance.")
	return true

func server_status(status):
	if status.has('server_status'):
		return false
	if server.upgrade_level['cpu'] > 0:
		status['server_status'] = true
		if status.has('server_status_shown'):
			return false
	status['server_status_shown'] = true
	send_output("You can get an overview of your server status using the commands 'status', 'ps' and 'queue'. Read the corresponding man pages to get more information.")
	send_output(" ")
	if server.upgrade_level['cpu'] == 0:
		send_output("When you run ps, you will (probably) see that the server is mostly working on compute requests.")
		send_output("You can upgrade your cpu so it runs faster using the command 'buy_upgrade cpu'.")
	else:
		send_output("You already upgraded your cpu, nice!")
	send_output("You can also buy upgrades for 'disk' (so you can install more services), 'ram' (so more services can run at the same time), and 'queue' (so more requests can be in the queue at the same time.")
	send_output("Each further upgrade will be more expensive")
	return true

func complicated_requests(status):
	if status.has('complicated_requests'):
		return false
	if not has_request(Root.servers[0], 'html') and not has_request(Root.servers[0], 'http') and not has_request(Root.servers[0], 'auth'):
		send_output("Please try again later. The condition for the next step is not yet fulfilled.")
		return true
	if has_service(Root.servers[0], 'php') or has_service(Root.servers[0], 'ldap'):
		status['complicated_requests'] = true
		return false
	status['complicated_requests'] = true
	send_output("You have now more complicated requests in your queue. These requests will generate new, simpler requests. Check the man page of the request type to get more information.")
	send_output("You should install new services to handle those complicated requests.")
	send_output("These new requests will increase the load on your system. You should probably upgrade your system a bit, especially the queue.")
	return true

func mail_intro(status):
	if status.has('mail_intro'):
		return false
	status['mail_intro'] = true
	send_output("From time to time users will send you emails (often if they are unhappy).")
	send_output("You can see the number of unread mails by running 'mail'.")
	send_output("To read mails, you can use the 'cat' command. The mails are stored in '/var/mail'.")
	send_output("You can list all mails by running 'ls /var/mail'. Should the output be too long, run 'ls /var/mail | more'. This will split the output and display a new line each time you press a key. You can use this also for other commands with long output.")
	send_output("As a reminder: by pressing TAB the file name will automatically be completed.")
	send_output("However, there is a much more convenient way: with 'mail show' you can read all unread mails at once.")
	return true

func buy_new_server(status):
	if status.has('buy_new_server'):
		return false
	if len(Root.servers) > 1:
		status['buy_new_server'] = true
		return false
	if Root.money < Root.new_server_price():
		send_output("You don't have enough money to continue.")
		return true
	send_output("To better handle the load of the requests you should buy a second server.")
	send_output("Do this now with 'buy_server' and you will learn how to configure everything in the next step.")
	return true

func buy_connection(status):
	if status.has('buy_connection'):
		return false
	if len(Root.servers[0].connections) > 0:
		status['buy_connection'] = true
		return false
	if Root.money < Root.new_connection_price(Root.servers[0], Root.servers[1]):
		send_output("You don't have enough money to continue.")
		return true
	send_output("Now that you have a shiny new server, you should configure it correctly.")
	send_output("You can see all your servers with 'servers'. You can switch to one of your servers using the 'connect' command.")
	send_output("First, you need to buy a new connection between the two servers.")
	send_output("Do this now with 'buy_connection'.\nYou can then check the new connection using 'ping'.")
	send_output("It takes " + str(Server.CONNECTION_DELAY) + " time units for a request to travel from one server to the next.")
	send_output("Hint: it might be helpful to draw your network topology on a piece of paper to keep a good overview.")
	return true

func configure_new_server(status):
	if status.has('configure_new_server'):
		return false
	if not has_service(Root.servers[0], 'compute') and has_service(Root.servers[1], 'compute') and is_forwarded(Root.servers[0], 'compute', Root.servers[1]):
		status['configure_new_server'] = true
		return false
	send_output("With the new connection in place you can configure the servers to use the connection.")
	send_output("As an example, the compute requests should be forwarded to the new server, where they are handled. The following steps are necessary (make sure you execute the commands on the correct server):")
	if has_service(Root.servers[0], 'compute'):
		send_output("- Uninstall compute from " + Root.servers[0].server_name + ".")
	if not has_service(Root.servers[1], 'compute'):
		send_output("- Install compute on " + Root.servers[1].server_name + ".")
	if not is_forwarded(Root.servers[0], 'compute', Root.servers[1]):
		send_output("- Forward compute requests from " + Root.servers[0].server_name + " to " + Root.servers[1].server_name + ".")
		send_output("  To setup a forwarding rule, use the 'set_route' command on " + Root.servers[0].server_name + ".")
	send_output("Remember, you can get the current configuration with 'ps' and 'routes'.")
	return true

func basic_setup_complete(status):
	if status.has('basic_setup_complete'):
		return false
	status['basic_setup_complete'] = true
	send_output("You completed the basic tutorial. You can now build your network to handle the requests efficiently.")
	send_output("Once you have a lot of angry users, you might want to come back to learn how to protect yourself against DDoS attacks.")
	return true


func handle_tutorial_basic(status):
	if initial_welcome(status):
		return
	if check_queue(status):
		return
	if install_initial_services(status):
		return
	if money_intro(status):
		return
	if server_status(status):
		return
	if mail_intro(status):
		return
	if complicated_requests(status):
		return
	if buy_new_server(status):
		return
	if buy_connection(status):
		return
	if configure_new_server(status):
		return
	if basic_setup_complete(status):
		return

func contract_intro(status):
	if status.has('contract_intro'):
		return false
	if len(ContractHandler.available_contracts) == 0:
		return false
	status['contract_intro'] = true
	send_output("You have received an email with an offer for a contract.")
	send_output("Contracts offer you a large amount of money if you can handle them. However, if you fail to complete all the requests you will have to pay half of the contract sum.")
	send_output("You can accept a contract by using the 'accept_contract' command.")
	send_output(" ")
	send_output("The mail contains a lot of valuable information. You can see the request types that will arrive and you can see the ip address from where they will be sent.")
	send_output("You can use this information to prepare your system by installing firewall rules (using iptables) and setting forwarding rules.")
	return true

func firewall_intro(status):
	if status.has('firewall_intro'):
		return false
	status['firewall_intro'] = true
	send_output("You can add firewall rules to your servers. This allows you to block certain requests by request type and/or source ip range.")
	send_output("Within your network this is mostly useful to route packets based on the source ip range: add a forwarding rule to the destination server and then block all other ip ranges on this destination server. The sending server will try to send the failed reqeusts to other servers listed in the forwarding rules. This is mostly useful in combination with contracts.")
	send_output("If you want to prevent a type of request from entering the network you have to block it on your ingress server (" + Root.servers[0].server_name + "). Note however that these blocked requests count as failed requests and will impact the users happiness.")
	send_output("Blocking requests on the ingress for a certain ip range is useful to block DDoS traffic if you know where it originates.")
	send_output(" ")
	send_output("To manipulate the firewall rules, use 'iptables' and 'set_iptables'. The configuration consists of a list of rules and the first applicable rule will be applied. See the man page for more details.")
	return true

func ddos_intro(status):
	if status.has('ddos_intro'):
		return false
	if Root.daily_request_complete_fake == 0:
		return false
	status['ddos_intro'] = true
	send_output("As you can see in the daily report mails, there are some DDoS requests in your network. These requests will not give you any money but they use ressources. You should try to filter them out.")
	send_output("In a first step you can install the ddos service which will automatically check all requests before they are handled. If the request is a ddos request, it will be converted to a request of type ddos and can be sent to the blackhole service. Otherwise it will be handled as usual.")
	send_output("However, this takes a lot of ressources. Furthermore, in some cases, a valid request is wrongly detected as ddos. To reduce this, you can check a request several times and thus reducing the risk.")
	send_output("To reduce the load on the system, you can decide to only check some percentage of all requests (the so called sample rate). You can set both of these settings with 'set_ddos' (e.g. set_ddos * 50 2).")
	send_output("In the next step you will learn how to filter and adapt the settings based on the source ip address.")
	return true

func ddos_advanced(status):
	if status.has('ddos_advanced'):
		return false
	if not status.has('ddos_intro'):
		return false
	status['ddos_advanced'] = true
	send_output("Filtering all the traffic for DDoS traffic is a heavy load on your system. By using the analyzer service, you can get more information about the DDoS traffic.")
	send_output("It requires a few ddos requests and will then write the source ip address into /var/log/analyzer.log. Hopefully, most of the requests come from the same ip range (i.e. the first part of the ip address is the same). You can then add rules for this ip range.")
	send_output("For example, you can block all traffic from this ip range on your ingress server (" + Root.servers[0].server_name + "). Or you can change the sample rate and check count for ddos protection for this range.")
	send_output("A possible setup would be to sample a small amount of all the traffic and send it to the analyzer server. For ip ranges that you identify, you can then either block them or increase the sample rate for them and send the detected ddos requests to a black hole service.")
	return true

func handle_advanced_tutorial(status):
	if contract_intro(status):
		return
	if firewall_intro(status):
		return
	if ddos_intro(status):
		return
	give_useful_hint(status)

func queue_full(status):
	var found = false
	for server in Root.servers:
		if len(server.input_queue) + server.incoming_requests_count > server.queue_length * 0.8:
			found = true
			send_output("The queue of server " + server.server_name + " is full.")
			var cpu = float(Root.average(server.used_cpu_cycles)) / server.cpu_cycles
			if cpu > 0.9:
				send_output("  CPU usage is " + str(int(100 * cpu)) + "%, try to upgrade the cpu\n    or redirect requests to other servers.")
			var bad_types = {}
			var rtype_count = {}
			var ddos_pending = 0
			for request in server.input_queue:
				if not rtype_count.has(request.type):
					rtype_count[request.type] = 0
				rtype_count[request.type] += 1
				var found_service = false
				if request.ddos_check_count > 0:
					ddos_pending += 1
				for service in server.installed_services:
					for rtype in service.type.inputs.keys():
						if rtype == request.type:
							found_service = true
				if not found_service:
					bad_types[request.type] = true
			if ddos_pending > server.queue_length * 0.5:
				send_output("  For many requests the ddos check is pending.\n    Try to increase the ddos check capacity or reduce the sample rate.")
			if bad_types:
				for rtype in bad_types.keys():
					var forwards = server.fs_root.open("etc/requests/" + rtype.request_name)
					if not forwards or not forwards.content:
						forwards = server.fs_root.open("etc/requests/*")
					if not forwards or not forwards.content:
						send_output("  There is no service installed and no rule defined to handle requests of type\n    " + rtype.full_name + ".")
						continue
					var found_forward = false
					for line in forwards.content.split('\n', false):
						var oserver = Root.resolve_ip(Root.resolve_name(line))
						if len(oserver.input_queue) + oserver.incoming_requests_count < oserver.queue_length * 0.9:
							found_forward = true
					if not found_forward:
						send_output("  There is no service installed to handle requests of type\n    " + rtype.full_name + " and all servers that are\n    valid routes have full queues.")
					else:
						send_output("  There is no service installed to handle requests of type\n    " + rtype.full_name + " but there are routes configured.")
			else:
				send_output("  Try to increase the capacity by installing more services of the same type.")
				var mav = 0
				var mael = null
				for rtype in rtype_count.keys():
					if rtype_count[rtype] >= mav:
						mael = rtype
						mav = rtype_count[rtype]
				if mael:
					send_output("    " + mael.full_name + " is the most common request type in the queue.")

	return found

func give_useful_hint(status):
	if queue_full(status):
		return
	send_output("There are currently no hints available.")
	# TODO implement

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
	if len(args) == 2:
		match args[1]:
			'basic':
				status['basic_setup_complete'] = true
			'finished':
				status['basic_setup_complete'] = true
				status['finished'] = true
			_:
				send_output('Unknown checkpoint.')
				return 1
	elif not status.has('basic_setup_complete'):
		handle_tutorial_basic(status)
	elif not status.has('finished'):
		handle_advanced_tutorial(status)
	else:
		give_useful_hint(status)
	config.content = ""
	for key in status.keys():
		config.content += key + "=" + str(status[key]) + "\n"
	return 0
