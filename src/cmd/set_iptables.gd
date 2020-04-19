extends Process

func usage():
	send_output('usage: set_iptables <request_type> [<rule> ...]')

func help():
	send_output("Set iptables firewall configuration.\nRequest type can be * to match everything.\nA rule is either allow or deny. It can be prefixed by an ip range (e.g. 10.0.0.0/24). Only /24 ranges are possible.\nThe server will only accept requests if the rules for a request evaluate to allow or no rule is specified\n")
	send_output("\nExample usage:\nset_iptables sql 10.0.0.0/24 deny 12.0.0.0/24 allow deny\n")
	usage()
	send_output("\nAlso see: iptables")

func run(args):
	if not server:
		send_output('Can only run on a server')
		return 1
	if len(args) < 2:
		usage()
		return 1
	if not RequestHandler.request_types.has(args[1]) and args[1] != '*':
		send_output('Invalid request type')
		return 1
	var rules = ""
	var i = 2
	while i < len(args):
		if args[i].find('/24') != -1:
			if i + 1 == len(args):
				send_output('Missing rule after ' + args[i])
				return 1
			if args[i+1] != 'allow' and args[i+1] != 'deny':
				send_output('Only allow or deny are allowed as rules')
				return 1
			rules += args[i] + " " + args[i+1] + "\n"
			i += 1
		else:
			if args[i] != 'allow' and args[i] != 'deny':
				send_output('Only allow or deny are allowed as rules')
				return 1
			rules += args[i] + "\n"
			i += 1
		i += 1
	server.fs_root.open('etc/iptables/' + args[1], true).content = rules
	return 0
