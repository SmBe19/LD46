extends Process

var variables = {}
var aliases = {}
var home = "/"
var fs_home = FSDir.new("/", null)
var last_status = 0

func _init():
	register_for_keypress()

func run(args):
	send_output("This is sh v0.0.1")
	fs_root = fs_home
	cwd = fs_root
	connect_server(['connect', 'shoutr'])
	while true:
		var line = yield(readline(prompt()), "completed")
		var cmd = line.split(' ', false) 
		if len(cmd) == 0:
			continue
		
		for i in len(cmd):
			if cmd[i].begins_with('$'):
				cmd[i] = lookup_var(cmd[i].right(1))
			if cmd[i].begins_with('~'):
				cmd[i] = home + cmd[i].right(1)
		
		if cmd[0] in aliases:
			cmd[0] = aliases[cmd[0]]
		
		match cmd[0]:
			"cd":
				cd(cmd)
			"set":
				set_var(cmd)
			"help":
				help(cmd)
			"logout":
				logout(cmd)
			"connect":
				connect_server(cmd)
			_:
				if cmd[0].is_valid_identifier():
					var script = load("res://src/cmd/" + cmd[0] + ".gd")
					if script != null:
						var process = script.new()
						process.output_process = output_process
						process.server = server
						process.fs_root = fs_root
						process.cwd = cwd
						var res = process.run(cmd)
						if res is GDScriptFunctionState:
							res = yield(res, "completed")
						send_output(cmd[0] + " returned " + str(res))
					else:
						send_output(cmd[0] + ": command not found")
				else:
					send_output(cmd[0] + ": command not found")

func prompt():
	if server:
		return server.server_name + " > "
	return "> "

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
	
	cwd = newcwd
	pass

func logout(args):
	if server != null:
		cwd = fs_home
		server = null


func connect_server(args):
	if len(args) != 2:
		send_output("usage: connect <server_name>")
	var ip = Root.resolve_name(args[1])
	server = Root.resolve_ip(ip)
	if not server:
		send_output("Server " + args[1] + " not found")
		return
	fs_root = server.fs_root
	cwd = fs_root

func help(args):
	send_output("git gud")

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
		output_process.set_line(output_process.current_line-1, prompt + line)
	return line