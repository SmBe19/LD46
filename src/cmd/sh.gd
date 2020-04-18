extends Process

var variables = {}
var aliases = {}
var home = "/"
var last_status = 0

func _init(output).(output):
	register_for_keypress()

func run(args):
	send_output("This is sh v0.0.1")
	while true:
		var line = yield(readline("> "), "completed")
		send_output("> " + line)
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
			"echo":
				echo(cmd)
			"cd":
				cd(cmd)
			"pwd":
				pwd(cmd)
			"set":
				set_var(cmd)
			"help":
				help(cmd)
			"mkdir":
				mkdir(cmd)
			"ls":
				ls(cmd)
			"touch":
				touch(cmd)
			"cat":
				cat(cmd)
			_:
				send_output("Unknown command: " + cmd[0])

func cat(cmd):
	if len(cmd) < 2:
		send_output('usage: cat <file>')
		return
	var file = self.cwd.open(cmd[1])
	if file == null:
		send_output("touch: no such file or directory")
	send_output(file.content)

func echo(cmd):
	var line = ""
	for i in range(1,len(cmd)):
		if i != 1:
			line += " "
		line += cmd[i]
	send_output(line)

func mkdir(cmd):
	if len(cmd) < 2:
		send_output('usage: mkdir <dir>')
		return
	var error = self.cwd.mkdir(cmd[1])
	if error != "":
		send_output("mkdir: " + error)

func ls(args):
	if len(args) == 1:
		for key in self.cwd.children.keys():
			send_output(" " + key)
	else:
		for i in range(1, len(args)):
			send_output(args[i] + ":")
			var node = self.cwd.get_node(args[i])
			if node == null:
				send_output("ls: " + args[i] + ": file not found")
			else:
				if node.is_dir():
					for key in node.children.keys():
						send_output(" " + key)
				else:
					send_output(" " + node.name)

func touch(args):
	if len(args) < 2:
		send_output('usage: touch <file>')
		return
	var file = self.cwd.open(args[1], true)
	if file == null:
		send_output("touch: no such file or directory")

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

func pwd(args):
	send_output(cwd.full_path())

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
	while true:
		var key = yield(output_process, "key_pressed")
		print(key)
		if key == KEY_BACKSPACE:
			line.erase(len(line)-1, 1)
		if key == KEY_ENTER:
			break
		if key >= KEY_SPACE && key <= KEY_ASCIITILDE:
			line += char(key)
		#}send_output(line)
	return line
