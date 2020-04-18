extends Node

class_name Request

var Self = load("request.gd")

signal request_fulfilled(request)

var id : int
var type : RequestType

func _init(request_id, request_type):
	self.id = request_id
	self.type = request_type
	
func process():
	var ret = []
	for t in type.requirements:
		ret.append(Self.new(id, t))
		ret[-1].connect("request_fulfilled", self, "child_fulfilled")
	if len(ret) == 0:
		emit_signal("request_fulfilled", self)
	return ret
	
var _children_fulfilled = 0

func child_fulfilled(request):
	_children_fulfilled += 1
	assert(_children_fulfilled <= len(type.requirements))
	if _children_fulfilled == len(type.requirements):
		emit_signal("request_fulfilled", self)
