extends Node

class_name Mail

var content : String
var subject : String
var sender : String
var sender_name : String

func _init(s, c, user):
	subject = s
	content = c
	content = content.replace("$senderName", user.type.user_name)
	content = content.replace("$senderEmail", user.type.mail)
	content = content.replace("$receiverEmail", "info@shoutr.io")
	sender = user.type.mail
	sender_name = user.type.user_name

func format():
	var ret = ""
	ret += "Delivered-To: root@shoutr.io\n"
	ret += "Received: from outgoing.%s\n" % sender.substr(sender.find_last('@') + 1)
	ret += "    by mail.shoutr.io (Postfixr)\n"
	ret += "    for<info@shoutr.io>\n"
	ret += "From: %s <%s>\n" % [sender_name, sender]
	ret += "To: Shoutr Services <info@shoutr.io>\n"
	ret += "Subject: %s\n" % subject
	ret += content
	return ret
