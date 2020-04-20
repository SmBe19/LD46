extends Node

class_name ContractType

var requests : Dictionary
var mailSubject : String
var mailContent : String
var reward : float
var time_limit : int
var repeating : bool

func _init(json):
	requests = Dictionary(json["requests"])
	mailSubject = str(json["mailSubject"])
	mailContent = str(json["mailContent"])
	reward = float(json["reward"])
	time_limit = int(json["timeLimit"])
	repeating = bool(json["repeating"]) if "repeating" in json else false

