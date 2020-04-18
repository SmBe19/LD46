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
	
func help():
	send_output("Help! I need somebody, help! Help me!")

func usage():
	send_output("Don't treat my like a tool")

func get_input():
	if input_queue.empty():
		yield(self, "input_received")
	return input_queue.pop_front()

func receive_input(input):
	input_queue.append(input)
	emit_signal("input_received")

func receive_input_list(input):
	receive_input(input.join("\n"))

func register_for_keypress():
	if output_process is Terminal:
		output_process.connect("key_pressed", self, "receive_keypress")

func unregister_for_keypress():
	if output_process is Terminal:
		output_process.disconnect("key_pressed", self, "receive_keypress")

func spawn_subprocess(name):
	if not name.is_valid_identifier():
		return (name + ": command not found")
	var script = load("res://src/cmd/" + name + ".gd")
	if script == null:
		return (name + ": command not found")
		
	var process = script.new()
	process.output_process = output_process
	process.server = server
	process.fs_root = fs_root
	process.cwd = cwd
	return process

func receive_keypress(key):
	pass
	
func send_output(output):
	output_process.receive_input(output)

func send_output_list(output):
	output_process.receive_input_list(output)
