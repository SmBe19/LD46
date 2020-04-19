extends Process

var variables = {}
var aliases = {}
var home = "/"
var fs_home = FSDir.new("/", null)
var last_status = 0

var history = []
var history_index = 0

var commands = []

func _init():
	register_for_keypress()
	var dir = Directory.new()
	if dir.open("res://src/cmd") == OK:
		dir.list_dir_begin()
		var fname = dir.get_next()
		while fname != "":
			if fname.ends_with(".gd"):
				commands.append(fname.left(len(fname) - 3))
			fname = dir.get_next()
		commands += ["cd", "set", "help", "logout", "connect"]
		commands.erase("sh")
		commands.sort()

func init_fs(fs):
	fs.mkdir('bin')
	fs.mkdir('usr/bin', true)
	var bin = fs.get_node('bin')
	var my_commands = commands.duplicate()
	my_commands.append('sh')
	my_commands.sort()
	for command in my_commands:
		bin.open(command, true).content = command

func run(args):
	send_output("This is sh v0.0.1")
	fs_root = fs_home
	cwd = fs_root
	init_fs(fs_root)
	connect_server(['connect', 'shoutr'])
	while true:
		var line = yield(readline(prompt()), "completed")
		var cmd = line.split(' ', false) 
		if len(cmd) == 0:
			continue
		
		history.append(line)
		history_index = len(history)
		
		for i in len(cmd):
			if cmd[i].begins_with('$'):
				cmd[i] = lookup_var(cmd[i].right(1))
			if cmd[i].begins_with('~'):
				cmd[i] = home + cmd[i].right(1)
		
		if cmd[0] in aliases:
			cmd[0] = aliases[cmd[0]]
		
		var matched = true;
		match cmd[0]:
			"cd":
				cd(cmd)
			"set":
				set_var(cmd)
			"logout":
				logout(cmd)
			"connect":
				connect_server(cmd)
			_:
				matched = false
		if matched:
			continue
		var process = spawn_subprocess(cmd[0])
		if not process is Process:
			send_output(process)
			continue
		var res = process.run(cmd)
		if res is GDScriptFunctionState:
			res = yield(res, "completed")
		if res != 0:
			send_output(cmd[0] + " returned error code " + str(res) + " ")

func prompt():
	if server:
		return server.server_name + ":" + cwd.full_path() + " > "
	return cwd.full_path() + " > "

func cd(args):
	var dir
	if len(args) < 2:
		dir = home
	else:
		dir = args[1]
	var newcwd
	if dir.begins_with("/"):
		newcwd = fs_root.get_node(dir.right(1))
	else:
		newcwd = cwd.get_node(dir)
	
	if newcwd == null:
		send_output("cd: no such file or directory")
		return
	
	cwd = newcwd

func logout(args):
	if server != null:
		cwd = fs_home
		server = null


func connect_server(args):
	if len(args) != 2:
		send_output("usage: connect <server_name>")
		return
	var ip = Root.resolve_name(args[1])
	server = Root.resolve_ip(ip)
	if not server:
		send_output("Server " + args[1] + " not found")
		return
	fs_root = server.fs_root
	cwd = fs_root
	init_fs(fs_root)

func set_var(args):
	if len(args) != 3:
		send_output("set: expected two parameters")
		return
	match args[1]:
		"PWD":
			send_output("Use `cd` to change directories")
		"STATUS":
			send_output('Read only variable')
		"HOME":
			if !args[2].begins_with("/"):
				send_output("$HOME must be an absolute path")
			if fs_root.file_type(args[2].right(1)) != "dir":
				send_output("$HOME must be a directory")
			home = args[2]
		"USER":
			send_output("This is a single-user system")
		"PATH":
			send_output("Can't set $PATH")
		_:
			if args[1].is_valid_identifier():
				variables[args[1]] = args[2]
			else:
				send_output("Variables must be valid identifiers")

func lookup_var(name):
	match name:
		"PWD":
			return cwd.full_path()
		"?", "STATUS":
			return String(last_status)
		"HOME":
			return home
		"USER":
			return "root"
		"PATH":
			return "/bin"
		_:
			if variables.has(name):
				return variables[name]
			else:
				return ''

func complete(line: String) -> Array:
	var cmd = line.left(line.find_last(' ')).split(' ', false)
	var completion_seed = line.right(1+line.find_last(' '))
	
	if len(cmd) == 0:
		# complete command names
		if len(completion_seed) == 0:
			return commands
		var res = []
		for x in commands:
			if x.begins_with(completion_seed):
				res.append(x)
		return res
	match cmd[0]:
		"connect":
			var res = []
			for x in Root.dns.keys():
				if x.begins_with(completion_seed):
					res.append(x)
			return res
	return []

func readline(prompt: String) -> String:
	var line : String = ""
	send_output(prompt)
	output_process.cursor_y = output_process.current_line-1
	output_process.set_line(output_process.current_line-1, prompt + line)
	while true:
		output_process.cursor_x = len(prompt) + len(line)
		var key = yield(output_process, "key_pressed")
		if key == KEY_BACKSPACE:
			line.erase(len(line)-1, 1)
		if key == KEY_ENTER:
			break
		if key >= KEY_SPACE && key <= KEY_ASCIITILDE:
			line += char(key)
		if key == KEY_UP:
			history_index -= 1
			if history_index < 0:
				history_index = len(history)
			line = history[history_index] if history_index < len(history) else ""
		if key == KEY_DOWN:
			history_index += 1
			if history_index > len(history):
				history_index = 0
			line = history[history_index] if history_index < len(history) else ""
		if key == KEY_TAB:
			var completions = complete(line)
			if len(completions) == 1:
				var compl_start_ix = line.rfind(' ')
				if compl_start_ix < 0:
					line = completions[0] + ' '
				else:
					line = line.left(compl_start_ix+1) + completions[0]
			elif len(completions) == 0:
				pass
			else:
				send_output(prompt + line)
				output_process.current_line -= 1
				send_output_list(completions)
				send_output(prompt + line)
				output_process.cursor_y = output_process.current_line-1
		output_process.set_line(output_process.current_line-1, prompt + line)
	return line
