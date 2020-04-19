extends Node

class_name UserType

var user_name : String
var hacker : bool
var politeness : float

func _init(json):
	user_name = str(json["name"])
	hacker = bool(json["hacker"])
	politeness = float(json["politeness"])
