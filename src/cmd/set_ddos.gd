extends Process

func usage():
	send_output('usage: set_ddos <ip_prefix> <sample_rate> <check_count>')

func help():
	send_output("Set ddos configuration.\n")
	send_output("The ddos checker has a certain probability of marking a valid request as ddos.\nWith check_count the packet is inspected several times and thus this probability decreases.\nA request is only checked with a certain probability (given by sample_rate, a value between 0 and 100).\n")
	send_output("\nThese configs can be changed on an ip range basis (ip_prefix is the first part of the ip address, e.g. '10' denotes the ip range '10.0.0.0/8').\nUse * to set the default configuration.\n")
	usage()
	send_output("\nAlso see: ddos")

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 4:
		usage()
		return 1
	if not args[1].is_valid_integer() and args[1] != '*':
		send_output('Invalid ip prefix')
		return 1
	if not args[2].is_valid_integer():
		send_output('Invalid sample rate')
		return 1
	if not args[3].is_valid_integer():
		send_output('Invalid check count')
		return 1
	
	server.fs_root.mkdir('etc/ddos/' + args[1], true)
	server.fs_root.open('etc/ddos/' + args[1] + "/sample_rate", true).content = args[2]
	server.fs_root.open('etc/ddos/' + args[1] + "/check_count", true).content = args[3]
	return 0
