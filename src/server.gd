extends Node

class_name Server

var fs_root = FSDir.new("/", null)
var input_queue = []
var incoming_requests = []
var server_name = ""
var ip = ""
var connections = {}
var queue_length = 16
var disk = 131072
var ram = 4096
var cpu_cycles = 32
var used_disk = 0
var used_ram = 0
var used_cpu_cycles = 0
var installed_services = []
var last_service = 0

var error_servers = []
var error_requests = []
var error_services = []

func _init(server_name_, ip_):
	server_name = server_name_
	ip = ip_
	fs_root.mkdir("etc/requests", true)
	fs_root.mkdir("var/log", true)
	update_fs()

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

func forward_request(request):
	var file = fs_root.open("etc/requests/" + request.type.request_name)
	if not file or not file.content:
		if not error_requests.has(request.type.full_name):
			error_requests.append(request.type.full_name)
			write_log("forward.log", "No forwarding rule for " + request.type.full_name + ".")
		return false
	error_requests.erase(request.type.full_name)
	var forwards = file.content.split("\n")
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
		used_cpu_cycles = cpu_cycles - remaining_cpu
	for service in installed_services:
		if service.is_finished():
			used_ram -= service.type.ram
			var results = service.get_results()
			if results:
				for request in results:
					input_queue.append(request)
