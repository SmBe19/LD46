extends Process

func usage():
	send_output('usage: bitcoind')

func help():
	send_output("Display cryptocurrency balance and transaction history.\n")
	usage()
	
func run(args):
	if len(args) != 1:
		usage()
		return 1
	for entry in Root.money_log:
		send_output(entry)
	send_output("---")
	send_output("Current balance: $" + str(Root.money))
	return 0
