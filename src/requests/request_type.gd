extends Node

class_name RequestType

var requirements = []
var request_name : String
var human_name : String
var full_name : String
var level : int

var _json

func _init(json):
	request_name = str(json["name"])
	human_name = str(json["human_name"])
	full_name = human_name + " (" + request_name + ")"
	level = int(json["level"])
	_json = json

func parseRequirements():
	for requirement_json in _json["requirements"]:
		requirements.append(RequestRequirement.new(requirement_json))
		
