extends Node

class_name Terminal

const HEIGHT = 24
const WIDTH = 80

var buffer = []
var current_line = 0

func _init():
    for y in WIDTH:
        var line = []
        for x in HEIGHT:
            line.append(' ')
        buffer.append(line)

func scroll_buffer(by):
    assert (by > 0)

func _fill_line(line):
    while len(line) < WIDTH:
        line.append(' ')
    return line

func write_line(line):
    var new_lines = []
    var current_new_line = []
    for c in line:
        if c == '\n' || len(current_line) == WIDTH:
            new_lines.append(_fill_line(current_new_line))
        if c != '\n':
            current_new_line.append(c)
    if len(current_new_line) > 0:
        new_lines.append(_fill_line(current_new_line))
    while len(new_lines) > HEIGHT:
        new_lines.pop_front()
    current_line += len(new_lines)
    if current_line > HEIGHT:
        scroll_buffer(current_line - HEIGHT)
        current_line = HEIGHT
    for i in len(new_lines):
        buffer[current_line-i-1] = new_lines[-i-1]

func set_line(y, line):
    assert (0 <= y && y < HEIGHT)
    assert (len(line) <= WIDTH)
    buffer[y] = _fill_line(line)

func set_char(x, y, c):
    assert (0 <= x && x < WIDTH)
    assert (0 <= y && y < HEIGHT)
    buffer[y][x] = c

func clear_screen():
    for y in HEIGHT:
        set_line(y, '')
    current_line = 0

func receive_input(input):
    write_line(input)
