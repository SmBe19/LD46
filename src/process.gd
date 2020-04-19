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
	receive_input(PoolStringArray(input).join("\n"))

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

func page_output(output):
	if not output_process is Terminal:
		send_output("output not a tty")
		return 1
	output_process.cursor_x = -1
	output_process.cursor_y = -1
	var visual_lines = []
	for x in output.split('\n'):
		while len(x) > Terminal.WIDTH:
			visual_lines.append(x.left(Terminal.WIDTH-1) + ">")
			x = "..." + x.right(Terminal.WIDTH-1)
		visual_lines.append(x)
	var initial_scroll = Terminal.HEIGHT - 2
	for x in visual_lines:
		send_output(x)
		initial_scroll -= 1
		if initial_scroll <= 0 and output_process.current_line >= Terminal.HEIGHT-1:
			var key = yield(output_process, "key_pressed")
			if key == KEY_ESCAPE or key == ord('q'):
				return 0
	return 0
	
func readline_simple(prompt: String) -> String:
	var line : String = ""
	send_output(prompt)
	var available_width = Terminal.WIDTH - len(prompt) - 1
	output_process.cursor_y = output_process.current_line-1
	output_process.set_line(output_process.current_line-1, prompt + line)
	while true:
		output_process.cursor_x = len(prompt) + min(available_width, len(line))
		var key = yield(output_process, "key_pressed")
		if key == KEY_BACKSPACE:
			line.erase(len(line)-1, 1)
		if key == KEY_ENTER:
			break
		if key >= KEY_SPACE && key <= KEY_ASCIITILDE:
			line += char(key)
		output_process.set_line(output_process.current_line-1, prompt + line.right(len(line)-available_width))
	return line

func ask_money(price):
	while true:
		var res = readline_simple("This costs $" + str(price) + ". Do you want to buy [y/n]? ")
		if res is GDScriptFunctionState:
			res = yield(res, 'completed')
		if res == 'y':
			return true
		if res == 'n':
			return false
