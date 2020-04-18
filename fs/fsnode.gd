class_name FSNode
extends Reference

var name: String = ""
var parent: FSNode = self

	
func full_path() -> String:
	if parent != self:
		return parent.full_path() + "/" + name
	else:
		return name
