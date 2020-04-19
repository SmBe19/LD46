extends Node

var mails = []

func _ready():
	var config = read_json("res://cfg/mails.json")
	var constructors = []
	for request_json in config:
		var mail = MailType.new(request_json)
		mails.append(mail)
	

func read_json(path):
	var file = File.new()
	file.open(path, file.READ)	
	var json = file.get_as_text()
	var json_result = JSON.parse(json)
	file.close()
	return json_result.result

func generate_mail(difficulty):
	var index = randi() % len(mails)
	return mails[index]
