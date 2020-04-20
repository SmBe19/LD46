extends Process

func usage():
	send_output('usage: cmatrix')

func help():
	send_output("Display a matrix-style effect")
	usage()


const chars_dense =  "M#A89HFZRWB&"
const chars_sparse = "._,'`\"/\\|!?-"

var quit = false
var column_pos = []
var column_height = []

func update_char(col, row):
	var pos = column_pos[col]
	var height = column_height[col]
	var chr = ' '
	if row <= pos and row > pos - height:
		chr = chars_dense[randi() % len(chars_dense)]
	if row <= pos-height and row > pos - 2*height:
		chr = chars_sparse[randi() % len(chars_dense)]
	if row >= 0 and row < Terminal.HEIGHT:
		output_process.set_char(col, row, chr)

func run(args):
	if not output_process is Terminal:
		send_output("cmatrix: output not a tty")
		return 1
	output_process.connect("key_pressed", self, "receive_keypress")
	output_process.cursor_x = -1
	output_process.cursor_y = -1

	for col in Terminal.WIDTH:
		column_pos.append(-(randi() %Terminal.HEIGHT))
		column_height.append(4 + randi() % 4)
	
	output_process.clear_screen()
	while !quit:
		for col in Terminal.WIDTH:
			if col % 2 == 0:
				continue
			column_pos[col] += 1
			update_char(col, column_pos[col])
			update_char(col, column_pos[col] - column_height[col])
			update_char(col, column_pos[col] - 2*column_height[col])
			
			if column_pos[col] - 2*column_height[col] >= Terminal.HEIGHT:
				column_pos[col] = -1
				column_height[col] = 4 + randi() % 6
		yield(Root.get_tree().create_timer(0.1), "timeout")
	output_process.clear_screen()
	return 0

func receive_keypress(key):
	print(key)
	quit = true
	
