extends Node

class_name Process

var root = null
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
