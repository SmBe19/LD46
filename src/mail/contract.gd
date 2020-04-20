extends Node

class_name Contract

var type : ContractType
var user : User

func _init(type: ContractType, user: User):
	self.type = type
	self.user = user
	var mail = Mail.new(type.mailSubject, type.mailContent, user)
	print(mail.format())
	MailHandler.send_mail(mail)
