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
	return not running and not current_request and _request.ddos_check_count > 0 and _request.type.request_name != 'ddos'

func handle_request(request):
	if can_handle(request):
		current_request = request

func can_start():
	if running:
		return false
	return current_request != null

func is_finished():
	return running and cycles_used >= type.cpu * current_request.ddos_check_count

func get_results():
	var res = [current_request]
	var fake_fake = current_request.ddos_check_count > 0
	for i in current_request.ddos_check_count:
		if randf() > FALSE_POSITIVE_RATE:
			fake_fake = false
	current_request.ddos_check_count = 0
	if fake_fake:
		Root.daily_request_fake_detected_wrong += 1
	elif current_request.fake_request:
		Root.daily_request_fake_detected += 1
	if current_request.fake_request or fake_fake:
		res = [Request.new(Root.get_uuid(), current_request.root_id, current_request.source_ip, RequestHandler.request_types['ddos'])]
	current_request = null
	running = false
	return res
