extends Node

class_name Process

var input_queue = []
var output_process = null

var fs_root = null
var server = null
var cwd = null

signal input_received

func run(args):
	pass

func get_input():
	if input_queue.empty():
		yield(self, "input_received")
	return input_queue.pop_front()

func receive_input(input):
	input_queue.append(input)
	emit_signal("input_received")


func register_for_keypress():
	if output_process is Terminal:
		output_process.connect("key_pressed", self, "receive_keypress")

func unregister_for_keypress():
	if output_process is Terminal:
		output_process.disconnect("key_pressed", self, "receive_keypress")

func receive_keypress(key):
	pass
	
func send_output(output):
	output_process.receive_input(output)

func fs_get_node(filename: String):
	if filename.begins_with('/'):
		return fs_root.get_node(filename.right(1))
	else:
		return cwd.get_node(filename)
		
func fs_open(filename: String, create: bool = false):
	if filename.begins_with('/'):
		return fs_root.open(filename.right(1), create)
	else:
		return cwd.open(filename, create)
		
func fs_mkdir(filename: String, recursive: bool = false):
	if filename.begins_with('/'):
		return fs_root.mkdir(filename.right(1), recursive)
	else:
		return cwd.mkdir(filename, recursive)
