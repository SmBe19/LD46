extends Node

class_name MailType

var content : String
var subject : String
var happiness : float
var politeness : float

func _init(json):
	content = str(json["content"])
	subject = str(json["subject"])
	happiness = float(json["happiness"])
	politeness = float(json["politeness"])
