extends Node

class_name Request

signal request_fulfilled(request)

var id : int
var root_id : int
var start_tick : int
var source_ip : String
var type : RequestType
var fake_request : bool
var ddos_sampled : bool
var ddos_check_count : int

func _init(request_id, root_id, source_ip, request_type):
	self.id = request_id
	self.root_id = root_id
	self.source_ip = source_ip
	self.type = request_type
	self.start_tick = Root.game_tick
	self.fake_request = false
	self.ddos_sampled = false
	self.ddos_check_count = 0

var _children_left = 0

func process():
	var ret = []
	for t in type.requirements:
		for i in t.count:
			ret.append(get_script().new(Root.get_uuid(), root_id, source_ip, t.type))
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
