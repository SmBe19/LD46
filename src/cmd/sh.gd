extends Process

func usage():
	send_output('usage: sh')

func help():
	send_output("sh is the standard shell, used for executing programs\n")
	usage()

var variables = {}
var aliases = {
	'gatus': 'status',
	'gull': 'install',
	'gush': 'queue'
}
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
			if fname.ends_with(".gd") and not fname.begins_with('debug'):
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

func transform_cmd(line):
	var cmd = line.split(' ', false)
	if len(cmd) == 0:
		return null
	
	for i in len(cmd):
		if cmd[i].begins_with('$'):
			cmd[i] = lookup_var(cmd[i].right(1))
		if cmd[i].begins_with('~'):
			cmd[i] = home + cmd[i].right(1)
	
	if cmd[0] in aliases:
		cmd[0] = aliases[cmd[0]]
	return cmd


func spawn_cmd(cmd):
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
		return
	var process = spawn_subprocess(cmd[0])
	if not process is Process:
		send_output(process)
		return null
	return process


func run(args):
	send_output("This is sh v3.141")
	fs_root = fs_home
	cwd = fs_root
	init_fs(fs_root)
	connect_server(['connect', 'shoutr'])
	var cmds = []
	while true:
		if len(cmds) == 0 or cmds[0][0] != 'mail':
			spawn_cmd(["mail"]).check_mail()
		var line = yield(readline(prompt()), "completed")
		cmds = []
		if not line:
			continue
		history.append(line)
		history_index = len(history)

		var cmd_parts = line.split('|')
		var processes = []
		for part in cmd_parts:
			var cmd = transform_cmd(part)
			var process = spawn_cmd(cmd)
			if not process:
				continue
			processes.append(process)
			cmds.append(cmd)
		
		for i in len(processes)-1:
			processes[i].output_process = processes[i+1]
		
		for i in len(processes):
			var res = processes[i].run(cmds[i])
			if res is GDScriptFunctionState:
				res = yield(res, "completed")
			if res != 0:
				send_output(cmds[i][0] + " returned error code " + str(res))
				break

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
		
	if !newcwd.is_dir():
		send_output("cd: not a directory")
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
		"connect","ping","buy_connection":
			var res = []
			for x in Root.dns.keys():
				if x.begins_with(completion_seed):
					res.append(x)
			return res
		"set_iptables","set_route":
			var res = []
			for x in RequestHandler.request_types.keys():
				if x.begins_with(completion_seed):
					res.append(x)
			return res
		"install","uninstall":
			var res = []
			for x in ServiceHandler.service_types.keys():
				if x.begins_with(completion_seed):
					res.append(x)
			return res
		"vi","cat","cd","ls","more","cp","mv","rm","rmdir":
			var res = []
			var last_dir = completion_seed.find_last('/')+1
			
			var dir_part = completion_seed.left(last_dir)
			var fname_part = completion_seed.right(last_dir)
			
			var dir_node = cwd.get_node(completion_seed.left(last_dir))
			if dir_node.is_dir():
				for f in dir_node.children.keys():
					if f == "." or f == "..":
						continue
					if f.begins_with(fname_part):
						var compl = dir_part + f
						if dir_node.children[f].is_dir():
							compl = compl + "/"
						res.append(compl)
			return res
			
			
	return []

func readline(prompt: String) -> String:
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
			var commonPrefix = ''
			while len(completions) > 0 && len(commonPrefix) < len(completions[0]):
				var valid = true
				var ch = len(commonPrefix)
				for s in completions:
					if len(s) < ch + 1 or s[ch] != completions[0][ch]:
						valid = false
				if valid:
					commonPrefix += completions[0][ch]
				else:
					break
			var oldLine = line
			if len(commonPrefix) > 0:
				var compl_start_ix = line.rfind(' ')
				if compl_start_ix < 0:
					if completions[0] == commonPrefix:
						line = commonPrefix + ' '
					else:
						line = commonPrefix
				else:
					line = line.left(compl_start_ix+1) + commonPrefix
			if len(completions) == 0:
				pass
			elif oldLine == line:
				send_output(prompt + line)
				output_process.current_line -= 1
				send_output_list(completions)
				send_output(prompt + line)
				output_process.cursor_y = output_process.current_line-1
		output_process.set_line(output_process.current_line-1, prompt + line.right(len(line)-available_width))
	return line
