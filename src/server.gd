extends Node

class_name Server

var fs_root = FSDir.new("/", null)
var input_queue = []
var incoming_requests = []
var server_name = ""
var ip = ""
var connections = {}
var queue_length = 128
var disk = 1024
var ram = 1024
var cpu_cycles = 256
var used_disk = 0
var used_ram = 0
var used_cpu_cycles = 0
var installed_services = []
var last_service = 0

func _init(server_name_, ip_):
	server_name = server_name_
	ip = ip_
	fs_root.mkdir("etc/requests", true)
	fs_root.mkdir("var/log", true)

func write_log(logname, content):
	var file = fs_root.open("var/log/" + logname, true)
	file.content += content + "\n"

func receive_request(request):
	if len(input_queue) + len(incoming_requests) < queue_length:
		incoming_requests.append(request)
		return true
	write_log("receive.log", "Receive queue full")
	return false

func process_incoming():
	for request in incoming_requests:
		input_queue.append(request)
	incoming_requests = []

func send_request(destination, request):
	if connections.has(destination):
		return connections[destination].receive_request(request)
	else:
		write_log("forward.log", "Server " + destination + " not connected.")
		return false

func forward_request(request):
    var file = fs_root.open("etc/requests/" + request.type.request_name)
    if not file or not file.content.trim():
        write_log("forward.log", "No forwarding rule for " + request.type.full_name + ".")
        return false
    var forwards = file.content.split("\n")
    var forward = forwards[randi() % len(forwards)]
    return send_request(Root.resolve_name(forward), request)

func install_service(service_name):
    var stype = ServiceHandler.get_type(service_name)
    if stype:
        if used_disk + stype.disk <= disk:
            used_disk += stype.disk
            var service = ServiceHandler.create_new_service(service_name)
            installed_services.append(service)
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
            if not forward_request(request):
                input_queue.append(request)
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
    for service in installed_services:
        if service.is_finished():
            used_ram -= service.type.ram
            var results = service.get_results()
            if results:
                for request in results:
                    input_queue.append(request)
