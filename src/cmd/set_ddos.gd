extends Process

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 4:
		send_output('usage: set_route <ip_prefix> <sample_rate> <check_count>')
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
