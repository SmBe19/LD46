extends Node

class_name ContractType

var requests : Dictionary
var mailSubject : String
var mailContent : String
var reward : float

func _init(json):
	requests = Dictionary(json["requests"])
	mailSubject = str(json["mailSubject"])
	mailContent = str(json["mailContent"])
	reward = float(json["reward"])

