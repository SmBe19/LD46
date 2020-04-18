class_name FSFile
extends FSNode

var content : String

func _ready():
	pass

func mkdir(dir: String, recursive: bool) -> String:
	return "Error: not a directory"

func open(filename: String, create: bool) -> FSFile:
	return null
