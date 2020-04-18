extends Node

var request_types = {}

func _ready():
	var config = read_json("res://cfg/requests.json")
	var constructors = []
	for request_json in config:
		var request = RequestType.new(request_json)
		request_types[request.request_name] = request
	for type in request_types.values():
		type.parseRequirements()
	

func read_json(path):
	var file = File.new()
	file.open(path, file.READ)	
	var json = file.get_as_text()
	var json_result = JSON.parse(json)
	file.close()
	return json_result.result
