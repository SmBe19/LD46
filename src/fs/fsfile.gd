class_name FSFile
extends FSNode

var content : String

func _init(name, parent).(name,parent):
	pass

func _ready():
	pass

func mkdir(dir: String, recursive: bool = false) -> String:
	return "Error: not a directory"

func open(filename: String, create: bool = false) -> FSFile:
	accessed = Root.game_tick
	return self
	
func file_type(filename: String) -> String:
	if len(filename) == 0:
		return "file"
	else:
		return ""

func get_node(filename: String) -> FSNode:
	if len(filename) == 0:
		return self
	return null
