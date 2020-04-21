extends Node

class_name Server

const AVERAGE_SPAN = 50
const STAT_SPAN = 300
const CONNECTION_DELAY = 25

const UPGRADE_PRICE = {
	'cpu': 256,
	'disk': 256,
	'ram': 256,
	'queue': 128,
}

var fs_root = FSDir.new("/", null)
var input_queue = []
var incoming_requests = []
var incoming_requests_count = 0
var server_name = ""
var ip = ""
var connections = {}
var upgrade_level = {
	'cpu': 0,
	'disk': 0,
	'ram': 0,
	'queue': 0,
}
var queue_length = 8
var disk = 4096
var ram = 1024
var cpu_cycles = 128
var used_disk = 0
var used_ram = 0
var used_ram_list = []
var used_cpu_cycles = []
var queue_length_list = [0]
var installed_services = []
var has_ddos_installed = false
var last_service = 0
var iptables_blocked = [0]
var ddos_checked = [0]
var ddos_detected = [0]

var error_servers = []
var error_requests = []
var error_forwarding = []
var error_services = []
var error_iptables = []
var error_ram = []

func _init(server_name_, ip_):
	server_name = server_name_
	ip = ip_
	fs_root.mkdir("etc/requests", true)
	fs_root.mkdir("etc/iptables", true)
	fs_root.mkdir("var/log", true)
	fs_root.mkdir("etc/ddos", true)
	fs_root.mkdir("etc/ddos/*", true)
	fs_root.open("etc/ddos/*/sample_rate", true).content = "100"
	fs_root.open("etc/ddos/*/check_count", true).content = "1"
	for i in CONNECTION_DELAY:
		incoming_requests.append([])
	update_fs()

func upgrade_price(item):
	return int(UPGRADE_PRICE[item] * pow(2.2, upgrade_level[item]))

func upgrade(item):
	var res = Root.buy_something(upgrade_price(item), 'Upgrade ' + item + ' for ' + server_name)
	if res:
		return res
	upgrade_level[item] += 1
	match item:
		'ram':
			ram *= 2
		'disk':
			disk *= 2
		'cpu':
			cpu_cycles *= 2
		'queue':
			queue_length *= 2
	return ''

func write_log(logname, content):
	var file = fs_root.open("var/log/" + logname, true)
	file.content += "[" + str(Root.game_tick) + "] " + content + "\n"

func get_ddos_sample_rate(request):
	var first_ip = request.source_ip.split('.', 1)[0]
	var file = fs_root.get_node("etc/ddos/" + first_ip + "/sample_rate")
	if file:
		return int(file.content) * 0.01
	return int(fs_root.open("etc/ddos/*/sample_rate").content) * 0.01

func get_ddos_check_count(request):
	var first_ip = request.source_ip.split('.', 1)[0]
	var file = fs_root.get_node("etc/ddos/" + first_ip + "/check_count")
	if file:
		return int(file.content)
	return int(fs_root.open("etc/ddos/*/check_count").content)

func receive_request(request):
	if len(input_queue) + incoming_requests_count < queue_length:
		if firewall(request):
			var sample_rate = get_ddos_sample_rate(request)
			request.ddos_sampled = randf() < sample_rate
			request.ddos_check_count = get_ddos_check_count(request) if has_ddos_installed and request.ddos_sampled else 0
			incoming_requests[CONNECTION_DELAY-1].append(request)
			incoming_requests_count += 1
			return true
		else:
			iptables_blocked[0] += 1
	return false

func process_incoming():
	for request in incoming_requests[0]:
		input_queue.append(request)
		incoming_requests_count -= 1
	for i in CONNECTION_DELAY - 1:
		incoming_requests[i] = incoming_requests[i+1]
	incoming_requests[CONNECTION_DELAY-1] = []

func send_request(destination, request):
	if connections.has(destination):
		error_servers.erase(destination)
		return connections[destination].receive_request(request)
	else:
		if not error_servers.has(destination):
			error_servers.append(destination)
			write_log("forward.log", "Server " + destination + " not connected.")
		return false

func firewall(request):
	var file = fs_root.open("etc/iptables/" + request.type.request_name)
	if not file or not file.content:
		file = fs_root.open("etc/iptables/*")
		if not file or not file.content:
			return true
	var lines = file.content.split("\n")
	for line in lines:
		if line.find('/8 ') != -1:
			var ipprefix = line.split(".", 1)[0]
			if request.source_ip.begins_with(ipprefix):
				if line.split(' ', 1)[1] == 'allow':
					return true
				write_log("iptables.log", "Request blocked for " + request.type.full_name + " from " + request.source_ip + ".")
				return false
		elif line == 'allow':
			error_iptables.erase(request.type.full_name)
			return true
		elif line == 'deny':
			if not error_iptables.has(request.type.full_name):
				error_iptables.append(request.type.full_name)
				write_log("iptables.log", "Request blocked for " + request.type.full_name + ".")
			return false
		else:
			if not error_iptables.has(request.type.full_name):
				error_iptables.append(request.type.full_name)
				write_log("iptables.log", "Invalid configuration for " + request.type.full_name + ".")
	return true

func forward_request(request):
	if request.ddos_check_count > 0:
		return false
	var file = fs_root.open("etc/requests/" + request.type.request_name)
	if not file or not file.content:
		file = fs_root.open("etc/requests/*")
		if not file or not file.content:
			if not error_requests.has(request.type.full_name):
				error_requests.append(request.type.full_name)
				write_log("forward.log", "No forwarding rule for " + request.type.full_name + ".")
			return false
	error_requests.erase(request.type.full_name)
	var forwards = file.content.split("\n", false)
	for i in 10:
		var forward = forwards[randi() % len(forwards)]
		if send_request(Root.resolve_name(forward), request):
			error_forwarding.erase(request.type.full_name)
			return true
	if not error_forwarding.has(request.type.full_name):
		error_forwarding.append(request.type.full_name)
		write_log("forward.log", "Can not forward " + request.type.full_name + ": server rejected request.")
	return false

func update_fs():
	fs_root.mkdir('usr/bin', true)
	fs_root.get_node('usr').children.erase('bin')
	fs_root.mkdir('usr/bin', true)
	var node = fs_root.get_node('/usr/bin')
	for service in installed_services:
		node.open(service.type.service_name, true).content = service.type.human_name
	fs_root.mkdir('/etc')
	var hosts = ip + " " + server_name + "\n"
	for ip in connections:
		hosts += ip + " " + connections[ip].server_name + "\n"
	fs_root.open('/etc/hosts', true).content = hosts

func install_service(service_name):
	var stype = ServiceHandler.get_type(service_name)
	if stype:
		if used_disk + stype.disk <= disk:
			used_disk += stype.disk
			var service = ServiceHandler.create_new_service(service_name)
			for i in AVERAGE_SPAN:
				service.cycles_in_last_tick.append(0)
			installed_services.append(service)
			if service_name == 'ddos':
				has_ddos_installed = true
			update_fs()
			return ''
		else:
			return 'Disk full'
	return 'Service type not found'

func uninstall_service(service_name):
	var uninstall_service = null
	for service in installed_services:
		if service.type.service_name == service_name:
			uninstall_service = service
			break
	if uninstall_service:
		for rtype in uninstall_service.request_queue.keys():
			for request in uninstall_service.request_queue[rtype]:
				input_queue.append(request)
		installed_services.erase(uninstall_service)
		used_disk -= uninstall_service.type.disk
		if service_name == 'ddos':
			has_ddos_installed = false
			for service in installed_services:
				if service.type.service_name == 'ddos':
					has_ddos_installed = true
			if not has_ddos_installed:
				for request in input_queue:
					request.ddos_sampled = false
					request.ddos_check_count = 0
		update_fs()
		return ''
	else:
		return 'Service not installed'

func handle_requests():
	var size = len(input_queue)
	for i in size:
		var request = input_queue.pop_front()
		var can_handle = false
		for service in installed_services:
			if service.is_running():
				continue
			if service.can_handle(request):
				service.handle_request(request)
				can_handle = true
				break
		if not can_handle:
			if not error_services.has(request.type.full_name):
				error_services.append(request.type.full_name)
				write_log("requests.log", "No service available for " + request.type.full_name + ".")
			if not forward_request(request):
				input_queue.append(request)
		else:
			error_services.erase(request.type.full_name)

func start_services():
	for service in installed_services:
		if service.can_start():
			if used_ram + service.type.ram <= ram:
				error_ram.erase(service.type.full_name)
				service.start()
				used_ram += service.type.ram
			else:
				if not error_ram.has(service.type.full_name):
					error_ram.append(service.type.full_name)
					write_log("services.log", "Can not start " + service.type.full_name + ": not enough memory.")


func run_services():
	if len(installed_services) > 0:
		var remaining_cpu = cpu_cycles
		var cycles_per_loop = max(1, remaining_cpu / 256)
		last_service = last_service % len(installed_services)
		var last_run = last_service
		while remaining_cpu > 0:
			last_service = (last_service + 1) % len(installed_services)
			if installed_services[last_service].is_running():
				installed_services[last_service].cycle(cycles_per_loop)
				remaining_cpu -= cycles_per_loop
				last_run = last_service
			elif last_run == last_service:
				break
		used_ram_list.append(used_ram)
		if len(used_ram_list) > AVERAGE_SPAN:
			used_ram_list.pop_front()
		used_cpu_cycles.append(cpu_cycles - remaining_cpu)
		if len(used_cpu_cycles) > AVERAGE_SPAN:
			used_cpu_cycles.pop_front()

func stop_services():
	for service in installed_services:
		if service.is_finished():
			used_ram -= service.type.ram
			if service.type.service_name == 'analyzer':
				for request in service.request_queue[RequestHandler.request_types['ddos']]:
					if request.fake_request:
						write_log('analyzer.log', 'DDoS request from ' + request.source_ip + '.')
			var results = service.get_results()
			if results:
				for request in results:
					input_queue.append(request)
					if service.type.service_name == 'ddos':
						ddos_checked[0] += 1
						Root.daily_request_fake_checked += 1
					if request.type.request_name == 'ddos':
						ddos_detected[0] += 1

func tick():
	handle_requests()
	start_services()
	for service in installed_services:
		service.cycles_in_current_tick = 0
	run_services()
	for service in installed_services:
		service.cycles_in_last_tick.append(service.cycles_in_current_tick)
		if len(service.cycles_in_last_tick) > AVERAGE_SPAN:
			service.cycles_in_last_tick.pop_front()
	stop_services()
	iptables_blocked.push_front(0)
	if len(iptables_blocked) > STAT_SPAN:
		iptables_blocked.pop_back()
	ddos_checked.push_front(0)
	if len(ddos_checked) > STAT_SPAN:
		ddos_checked.pop_back()
	ddos_detected.push_front(0)
	if len(ddos_detected) > STAT_SPAN:
		ddos_detected.pop_back()
	queue_length_list.append(len(input_queue) + incoming_requests_count)
	if len(queue_length_list) > STAT_SPAN:
		queue_length_list.pop_front()
