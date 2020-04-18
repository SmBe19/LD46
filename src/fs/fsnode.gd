class_name FSNode
extends Reference


func _init(n, p):
	if n == "/":
		name = ""
		parent = self
	else:
		name = n
		parent = p
	
var name: String = ""
var parent: FSNode = self

	
func full_path() -> String:
	if parent != self:
		return parent.full_path() + name
	else:
		return "/"

func is_dir():
	return false
