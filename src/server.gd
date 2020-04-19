extends Node

class_name Server

const AVERAGE_SPAN = 50

const UPGRADE_PRICE = {
	'cpu': 512,
	'disk': 256,
	'ram': 512,
	'queue': 1024,
}

var fs_root = FSDir.new("/", null)
var input_queue = []
var incoming_requests = []
var server_name = ""
var ip = ""
var connections = {}
var upgrade_level = {
	'cpu': 0,
	'disk': 0,
	'ram': 0,
	'queue': 0,
}
var queue_length = 16
var disk = 131072
var ram = 4096
var cpu_cycles = 32
var used_disk = 0
var used_ram = 0
var used_ram_list = []
var used_cpu_cycles = []
var installed_services = []
var last_service = 0

var error_servers = []
var error_requests = []
var error_services = []
var error_iptables = []

func _init(server_name_, ip_):
	server_name = server_name_
	ip = ip_
	fs_root.mkdir("etc/requests", true)
	fs_root.mkdir("etc/iptables", true)
	fs_root.mkdir("var/log", true)
	update_fs()

func upgrade_price(item):
	return UPGRADE_PRICE[item] * pow(2, upgrade_level[item])

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

func receive_request(request):
	if len(input_queue) + len(incoming_requests) < queue_length:
		incoming_requests.append(request)
		return true
	return false

func process_incoming():
	for request in incoming_requests:
		input_queue.append(request)
	incoming_requests = []

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
		return true
	var lines = file.content.split("\n")
	for line in lines:
		if line.find('/24 ') != -1:
			var ipprefix = line.split(".", 1)[0]
			if request.source_ip.begins_with(ipprefix):
				if line.split(' ', 1)[1] == 'allow':
					return true
				write_log("iptables.log", "Request blocked for " + request.type.full_name + " from " + request.source_ip + ".")
				return false
		elif line == 'allow':
			error_iptables.erase(request.type.full_name)
			return true
		elif line == 'drop':
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
	if not firewall(request):
		return true
	var file = fs_root.open("etc/requests/" + request.type.request_name)
	if not file or not file.content:
		if not error_requests.has(request.type.full_name):
			error_requests.append(request.type.full_name)
			write_log("forward.log", "No forwarding rule for " + request.type.full_name + ".")
		return false
	error_requests.erase(request.type.full_name)
	var forwards = file.content.split("\n", false)
	var forward = forwards[randi() % len(forwards)]
	return send_request(Root.resolve_name(forward), request)

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
		update_fs()
		return ''
	else:
		return 'Service not installed'

func tick():
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
				write_log("forward.log", "No service available for " + request.type.full_name + ".")
			if not forward_request(request):
				input_queue.append(request)
		else:
			error_services.erase(request.type.full_name)
	for service in installed_services:
		if service.can_start():
			if used_ram + service.type.ram <= ram:
				service.start()
				used_ram += service.type.ram
	for service in installed_services:
		service.cycles_in_current_tick = 0
	if len(installed_services) > 0:
		var remaining_cpu = cpu_cycles
		var last_run = last_service
		while remaining_cpu > 0:
			last_service = (last_service + 1) % len(installed_services)
			if installed_services[last_service].is_running():
				installed_services[last_service].cycle()
				remaining_cpu -= 1
				last_run = last_service
			elif last_run == last_service:
				break
		used_ram_list.append(used_ram)
		if len(used_ram_list) > AVERAGE_SPAN:
			used_ram_list.pop_front()
		used_cpu_cycles.append(cpu_cycles - remaining_cpu)
		if len(used_cpu_cycles) > AVERAGE_SPAN:
			used_cpu_cycles.pop_front()
	for service in installed_services:
		service.cycles_in_last_tick.append(service.cycles_in_current_tick)
		if len(service.cycles_in_last_tick) > AVERAGE_SPAN:
			service.cycles_in_last_tick.pop_front()
	for service in installed_services:
		if service.is_finished():
			used_ram -= service.type.ram
			var results = service.get_results()
			if results:
				for request in results:
					input_queue.append(request)
