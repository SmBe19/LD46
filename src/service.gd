extends Node

class_name Service

var service_name = ""
var request_type_in = {}
var disk = 0
var ram = 0
var cycles = 0
var request_queue = {}
var running = false
var cycles_used = 0

func _init(service_name_, request_type_in_, disk_, ram_, cycles_):
    service_name = service_name_
    request_type_in = request_type_in_
    disk = disk_
    ram = ram_
    cycles = cycles_
    for type in request_type_in_.keys():
        request_queue[type] = []

func can_handle(request):
    if running:
        return false
    var type = request.type
    return request_queue.has(type) and len(request_queue[type]) < request_type_in[type]

func handle_request(request):
    if can_handle(request):
        requests_queue[request.type].append(request)

func can_start():
    if running:
        return false
    for type in request_queue.keys():
        if len(request_queue[type]) < request_type_in[type]:
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
    return running and cycles_used >= cycles

func get_results():
    var res = []
    for type in request_queue.keys():
        for request in request_queue[type]:
            var new_requests = request.process()
            for req in new_requests:
                res.append(req)
    return res

func cycle():
    if running:
        cycles_used += 1
