extends Process

func run(args):
	if len(args) != 1:
		send_output('usage: bitcoind')
		return 1
	for entry in Root.money_log:
		send_output(entry)
	send_output("---")
	send_output("Current balance: $" + str(Root.money))
	return 0
