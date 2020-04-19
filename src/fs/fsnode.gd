class_name FSNode
extends Reference

var accessed : int
var created : int

func _init(n, p):
	created = 0 if Root == null else Root.game_tick
	accessed = created
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
		return parent.full_path() + name + "/"
	else:
		return "/"

func is_dir():
	return false
