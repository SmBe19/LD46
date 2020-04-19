extends Process

func help():
	send_output("Informs you about new mail. Mail is stored under /var/mail/ on the shoutr server.")
	usage()

func usage():
	send_output('usage: mail')

func run(args):
	send_output("No mail for root.")
	send_output("You have new mail.")
