extends Node

class_name MailType

var content : String
var subject : String
var type : String
var _json

func _init(json):
	_json = json
	content = str(json["content"])
	subject = str(json["subject"])
	type = str(json["type"])

func duplicate(flags:int=0):
	return get_script().new(_json)
	
