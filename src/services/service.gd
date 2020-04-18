extends Node

class_name Service

var type = null
var request_queue = {}
var running = false
var cycles_used = 0

func _init(type_):
    type = type_
    for rtype in type.inputs.keys():
        request_queue[rtype] = []

func can_handle(request):
    if running:
        return false
    var rtype = request.type
    return request_queue.has(rtype) and len(request_queue[rtype]) < type.inputs[rtype]

func handle_request(request):
    if can_handle(request):
        request_queue[request.type].append(request)

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
    return res

func cycle():
    if running:
        cycles_used += 1