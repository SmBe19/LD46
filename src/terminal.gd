extends Node

class_name Terminal

signal key_pressed(key)

const HEIGHT = 24
const WIDTH = 80

var buffer = []
var current_line = 0

var cursor_x = -1
var cursor_y = -1

func _init():
	for y in HEIGHT:
		var line = []
		for x in WIDTH:
			line.append(' ')
		buffer.append(line)

func _ready():
	set_process_input(true)

func scroll_buffer(by):
	assert (by > 0)
	if by >= HEIGHT:
		for i in HEIGHT:
			buffer[-i-1] = _fill_line([])
		return
	for i in HEIGHT - by:
		buffer[i] = buffer[i+by]
	for i in by:
		buffer[-i-1] = _fill_line([])

func _fill_line(line):
	while len(line) < WIDTH:
		line.append(' ')
	return line

func write_line(line):
	var new_lines = []
	var current_new_line = []
	for c in line:
		if c == '\n' || len(current_new_line) == WIDTH:
			new_lines.append(_fill_line(current_new_line))
			current_new_line = []
		else:
			current_new_line.append(c)
	if len(current_new_line) > 0:
		new_lines.append(_fill_line(current_new_line))
	while len(new_lines) > HEIGHT:
		new_lines.pop_front()
	current_line += len(new_lines)
	if current_line >= HEIGHT:
		scroll_buffer(current_line - HEIGHT + 1)
		current_line = HEIGHT - 1
	for i in len(new_lines):
		buffer[current_line-i-1] = new_lines[-i-1]

func set_line(y, line):
	assert (0 <= y && y < HEIGHT)
	assert (len(line) <= WIDTH)
	for i in len(line):
		buffer[y][i] = line[i]
	for i in range(len(line), WIDTH):
		buffer[y][i] = ' '

func set_char(x, y, c):
	assert (0 <= x && x < WIDTH)
	assert (0 <= y && y < HEIGHT)
	assert (len(c) == 1)
	buffer[y][x] = c

func clear_screen():
	for y in HEIGHT:
		set_line(y, '')
	current_line = 0

func receive_input(input):
	write_line(input)

func receive_input_list(input):
	input = input.duplicate()
	var res = ""
	var current_line = ""
	while input:
		while input and len(current_line) + len(input[0]) + 1 < WIDTH:
			if current_line:
				current_line += " "
			current_line += input[0]
			input.pop_front()
		if res:
			res += "\n"
		res += current_line
		current_line = ""
	write_line(res)
