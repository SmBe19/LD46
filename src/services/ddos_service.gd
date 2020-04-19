extends Service

class_name DDOSService

const FALSE_POSITIVE_RATE = 0.1

var current_request = null

func _init(type_).(type_):
	type = type_
	assert (type.service_name == 'ddos')
	for rtype in type.inputs.keys():
		request_queue[rtype] = []

func can_handle(_request):
	return not running and not current_request and _request.ddos_check_count > 0 and _request.type.request_name != 'fake'

func handle_request(request):
	if can_handle(request):
		current_request = request

func can_start():
	if running:
		return false
	return current_request != null

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
	var res = [current_request]
	current_request.ddos_check_count -= 1
	if current_request.fake_request or randf() < FALSE_POSITIVE_RATE:
		res = [Request.new(Root.get_uuid(), current_request.root_id, current_request.source_ip, RequestHandler.request_types['fake'])]
	current_request = null
	running = false
	return res

func cycle():
	if running:
		cycles_in_current_tick += 1
		cycles_used += 1
