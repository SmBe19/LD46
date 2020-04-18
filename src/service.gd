extends Node

class_name Service

var service_name = ""
var request_type_in = []
var request_type_out = []

func _init(service_name_, request_type_in_, request_type_out_):
    service_name = service_name_
    request_type_in = request_type_in_
    request_type_out = request_type_out_
