extends Node

class_name RequestRequirement

var count : int
var type

func _init(json):
	count = int(json["count"])
	type = RequestHandler.request_types[str(json["name"])]
