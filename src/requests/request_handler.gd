extends Node

var request_types = {}
var requests_by_difficulty = {}
var seen_requests = {}
var seen_ddos = false
var max_difficulty = 0

func _ready():
	var config = read_json("res://cfg/requests.json")
	var constructors = []
	for request_json in config:
		var request = RequestType.new(request_json)
		request_types[request.request_name] = request
		if not requests_by_difficulty.has(request.level):
			requests_by_difficulty[request.level] = []
		requests_by_difficulty[request.level].append(request)
		max_difficulty = max(request.level, max_difficulty)
	for type in request_types.values():
		type.parseRequirements()
	

func read_json(path):
	var file = File.new()
	file.open(path, file.READ)	
	var json = file.get_as_text()
	var json_result = JSON.parse(json)
	file.close()
	return json_result.result

func generate_request(difficulty):
	var index = randi() % len(requests_by_difficulty[difficulty])
	return requests_by_difficulty[difficulty][index]
