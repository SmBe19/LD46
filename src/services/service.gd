extends Node

class_name Service

var type = null
var request_queue = {}
var queue_size = 0
var running = false
var cycles_used = 0
var cycles_in_current_tick = 0
var cycles_in_last_tick = []

func _init(type_):
	type = type_
	for rtype in type.inputs.keys():
		request_queue[rtype] = []

func can_handle(request):
	if running:
		return false
	if request.ddos_check_count > 0:
		return false
	var rtype = request.type
	return request_queue.has(rtype) and len(request_queue[rtype]) < type.inputs[rtype]

func handle_request(request):
	if can_handle(request):
		request_queue[request.type].append(request)
		queue_size += 1

func can_start():
	if running:
		return false
	for rtype in request_queue.keys():
		if len(request_queue[rtype]) < type.inputs[rtype]:
			return false
	return true

func start():
	if not can_start():
		return
	running = true
	cycles_used = 0

func is_running():
	return running and not is_finished()

func is_finished():
	return running and cycles_used >= type.cpu

func get_results():
	var res = []
	for rtype in request_queue.keys():
		for request in request_queue[rtype]:
			var new_requests = request.process()
			for req in new_requests:
				res.append(req)
	running = false
	queue_size = 0
	for rtype in type.inputs.keys():
		request_queue[rtype] = []
	return res

func cycle():
	if running:
		cycles_in_current_tick += 1
		cycles_used += 1
