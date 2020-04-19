extends Node

var service_types = {}

func _ready():
	var config = RequestHandler.read_json("res://cfg/services.json")
	for service_json in config:
		var service = ServiceType.new(service_json)
		service_types[service.service_name] = service

func get_type(service_name):
	if service_types.has(service_name):
		return service_types[service_name]
	return null

func create_new_service(service_name):
	if service_types.has(service_name):
		if service_name == 'ddos':
			return DDOSService.new(service_types[service_name])
		return Service.new(service_types[service_name])
	return null
