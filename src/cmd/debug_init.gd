extends Process

func run(args):
	Root.money = 1e6
	Root.add_new_server('analyzer', Root.random_ip('10'))
	Root.add_new_server('apps', Root.random_ip('10'))
	Root.connect_servers(Root.servers[0], Root.servers[1])
	Root.connect_servers(Root.servers[0], Root.servers[2])
	for i in 4:
		for i in len(Root.servers):
			Root.servers[i].upgrade('cpu')
			Root.servers[i].upgrade('disk')
			Root.servers[i].upgrade('ram')
			Root.servers[i].upgrade('queue')
	for i in 5:
		Root.servers[0].install_service('ddos')
	Root.servers[0].install_service('blackhole')
	Root.servers[2].install_service('compute')
	Root.servers[2].install_service('database')
	Root.servers[2].install_service('apache')
	Root.servers[2].install_service('nginx')
	Root.servers[2].install_service('qmail')
	Root.servers[2].install_service('ldap')
	Root.servers[2].install_service('php')
	Root.servers[1].install_service('analyzer')
	server.fs_root.open('etc/requests/*', true).content = 'apps'
	server.fs_root.open('etc/requests/ddos', true).content = 'shoutr\nanalyzer\n'
	
	for i in 20:
		UserHandler.generate_user()
	return 0
