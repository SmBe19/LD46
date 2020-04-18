extends Node

class_name ServiceType

var service_name : String
var human_name : String
var inputs = {}
var cpu
var ram
var disk

func _init(json):
    service_name = str(json["name"])
    human_name = str(json["human_name"])
    cpu = int(json["resources"]["cpu"])
    ram = int(json["resources"]["ram"])
    disk = int(json["resources"]["hdd"])
    for input in json["inputs"]:
        inputs[RequestHandler.request_types[str(input["name"])]] = int(input["count"])
