extends Node

class_name Request

signal request_fulfilled(request)

var id : int
var root_id : int
var start_tick : int
var type : RequestType

func _init(request_id, root_id, request_type):
	self.id = request_id
	self.root_id = root_id
	self.type = request_type
	self.start_tick = Root.game_tick
	
	
var _children_left = 0

func process():
	var ret = []
	for t in type.requirements:
		for i in t.count:
			ret.append(get_script().new(Root.get_uuid(), root_id, t.type))
			ret[-1].connect("request_fulfilled", self, "child_fulfilled")
			_children_left += 1
	if _children_left == 0:
		emit_signal("request_fulfilled", self)
	return ret
	

func child_fulfilled(request):
	_children_left -= 1
	assert(_children_left >= 0)
	if _children_left == 0:
		emit_signal("request_fulfilled", self)
