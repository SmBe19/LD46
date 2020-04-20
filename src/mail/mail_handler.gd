extends Node

var mails = []
var mail_types = {}

func _ready():
	var config = read_json("res://cfg/mails.json")
	var constructors = []
	for request_json in config:
		var mail = MailType.new(request_json)
		mails.append(mail)
		if not mail_types.has(mail.type):
			mail_types[mail.type] = []
		mail_types[mail.type].append(mail)
	

func read_json(path):
	var file = File.new()
	file.open(path, file.READ)	
	var json = file.get_as_text()
	var json_result = JSON.parse(json)
	file.close()
	return json_result.result

func generate_mail(type, user):
	var index = randi() % len(mail_types[type])
	return Mail.new(mail_types[type][index], user)

func send_mail(mail):
	Root.servers[0].fs_root.mkdir('var/mail')
	var filename =  "%08d_%s" % [Root.game_tick, mail.subject.replace(" ", "_")]
	Root.servers[0].fs_root.open("var/mail/" + filename, true).content = mail.format()
