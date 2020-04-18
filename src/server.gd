extends Node

class_name Server

var root
var fs_root = FSDir.new("/", null)
var input_queue = []
var server_name = ""
var ip = ""
var connections = {}
var queue_length = 128
var disk = 1024
var ram = 1024
var cpu_cycles = 256
var services = []
var last_service = 0

func _init(root_, server_name_, ip_):
	root = root_
	server_name = server_name_
	ip = ip_
	fs_root.mkdir("/etc/requests", true)
	fs_root.mkdir("/var/logs", true)

func write_log(logname, content):
	var file = fs_root.open("/var/log/" + logname, true)
	file.content += content + "\n"

func receive_request(request):
	if len(input_queue) < queue_length:
		input_queue.append(request)
		return true
	return false

func send_request(destination, request):
	if connections.has(destination):
		connections[destination].receive_request(request)
	else:
		write_log("forward.log", "Server " + destination + " not connected.")

func forward_request(request):
	# TODO implement
	pass

func tick():
	var size = len(input_queue)
	for i in size:
		var request = input_queue.pop_front()
		var can_handle = false
		for service in services:
			if service.can_handle(request):
				service.start_handle(request)
				can_handle = true
				break
		if not can_handle:
			if not forward_request(request):
				input_queue.append(request)
	var remaining_cpu = cpu_cycles
	for service in services:
		var results = service.get_results()
		if results:
			for request in results:
				input_queue.append(request)
