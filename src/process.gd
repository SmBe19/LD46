extends Node

class_name Process

var input_queue = []
var output_process = null

signal input_received

func _init(output):
	output_process = output

func run(args):
	pass

func get_input():
	if input_queue.empty():
		yield(self, "input_received")
	return input_queue.pop_front()

func receive_input(input):
	input_queue.append(input)
	emit_signal("input_received")
	
func send_output(output):
	output_process.receive_input(output)
