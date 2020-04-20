extends Process

func help():
	send_output("Informs you about new mail. Mail is stored under /var/mail/ on the shoutr server.\n")
	usage()
	
func check_mail():
	var count = count_mail()
	if count > 0:
		if Root.servers[0] == server:
			send_output("You have new mail.")
		else:
			send_output("root@shoutr has new mail.")
	return count
	
func count_mail():
	var shoutr = Root.servers[0]
	var maildir = Root.servers[0].fs_root.get_node('var/mail')
	var count = 0
	if maildir is FSDir:
		for mail in maildir.children.values():
			if mail.accessed == mail.created:
				count += 1
	return count

func usage():
	send_output('usage: mail')

func run(args):
	var mails = check_mail()
	if mails > 0:
		send_output("%d unread mails in /var/mail" % mails)
	else:
		send_output("No mail for root.")
	return 0
