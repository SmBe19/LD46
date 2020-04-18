extends Node

class_name Server

var root
var fs_root = FSDir.new("/", null)
var input_queue = []
var name = ""
var ip = ""
var connections = {}
var disk = 1024
var ram = 1024
var cpu_cycles = 256
var services = []

func _init(root_, name_, ip_):
    root = root_
    name = name_
    ip = ip_
    fs_root.mkdir("/etc/requests", True)
    fs_root.mkdir("/var/logs", True)

func write_log(logname, content):
    var file = fs_root.open("/var/log/" + logname, True)
    file.content += content + "\n"

func receive_request(request):
    input_queue.append(request)

func send_request(destination, request):
    if connections.has(destination):
        connections[deistination].receive_request(request)
    else:
        write_log("forward.log", "Server " + destination + " not connected.")

func tick():
    if not input_queue.empty():
        request = input_queue.pop_front()
        # TODO process and forward

