class_name FSDir
extends FSNode


var children: Dictionary = {}

func _init():
	children["."] = self
	children[".."] = self.parent


func mkdir(dir: String, recursive: bool) -> String:
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
	var newdir = FSDir.new()
	newdir.name = components[0]
	newdir.parent = self
	children[components[0]] = newdir
	if len(components) > 1 && len(components[1]) > 0:
		return newdir.mkdir(components[1], recursive)
	return ""

func open(filename: String, create: bool) -> FSFile:
	var components = filename.split('/', true, 1)
	if len(components[0]) == 0:
		return null
	if children.has(components[0]):
		if len(components) > 1:
			if children[components[0]] is FSDir:
				return children[components[0]].open(components[1], create)
		else:
			if children[components[0]] is FSFile:
				return children[components[0]]
	else:
		if create && len(components) == 1:
			var newfile = FSFile.new()
			children[components[0]] = newfile
			return newfile
	return null
