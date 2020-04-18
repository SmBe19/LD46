extends Node

class_name Service

var service_name = ""
var request_type_in = []
var disk = 0
var ram = 0

func _init(service_name_, request_type_in_, disk_, ram_):
    service_name = service_name_
    request_type_in = request_type_in_
    disk = disk_
    ram = ram_

func can_handle(request):
    # TODO implement
    pass

func start_handle(request):
    pass

func is_running():
    pass

func get_results():
    pass

func cycle():
    # TODO implement
    pass
