class_name FSDir
extends FSNode


var children: Dictionary = {}

func _init(name,parent).(name,parent):
	children["."] = self
	children[".."] = self.parent

func is_dir() -> bool:
	return true

func mkdir(dir: String, recursive: bool = false) -> String:
	var components = dir.split('/', true, 1)
	if len(components[0]) == 0:
		return "Error: invalid path"
	if children.has(components[0]):
		if len(components) > 1 && len(components[1]) > 0:
			return children[components[0]].mkdir(components[1], recursive)
		else:
			return "Error: file/directory exists"
	else:
		if len(components) > 1 && len(components[1]) > 0:
			if !recursive:
				return "Error: no such file or directory"
	var newdir = get_script().new(components[0], self)
	children[components[0]] = newdir
	if len(components) > 1 && len(components[1]) > 0:
		return newdir.mkdir(components[1], recursive)
	return ""

func open(filename: String, create: bool = false) -> FSFile:
	var components = filename.split('/', true, 1)
	if len(components[0]) == 0:
		return null
	if children.has(components[0]):
		if len(components) > 1:
			if children[components[0]].is_dir():
				return children[components[0]].open(components[1], create)
		else:
			if children[components[0]] is FSFile:
				return children[components[0]]
	else:
		if create && len(components) == 1:
			var newfile = FSFile.new(components[0], self)
			children[components[0]] = newfile
			return newfile
	return null

func file_type(filename: String) -> String:
	if len(filename) == 0:
		return "dir"
	var components = filename.split('/', true, 1)
	if children.has(components[0]):
		if len(components) > 1 && len(components[1]) > 0:
			return children[components[0]].file_type(components[1])
		else:
			return children[components[0]].file_type("")
	return ""

func get_node(filename: String) -> FSNode:
	if len(filename) == 0:
		return self
	var components = filename.split('/', true, 1)
	if children.has(components[0]):
		if len(components) > 1 && len(components[1]) > 0:
			return children[components[0]].get_node(components[1])
		else:
			return children[components[0]]
	return null
