extends Process

func run(args):
	Root.money = 1e6
	Root.add_new_server('analyzer', Root.random_ip('10'))
	Root.add_new_server('apps', Root.random_ip('10'))
	Root.connect_servers(Root.servers[0], Root.servers[1])
	Root.connect_servers(Root.servers[0], Root.servers[2])
	Root.servers[0].install_service('ddos')
	Root.servers[0].install_service('blackhole')
	Root.servers[0].install_service('compute')
	Root.servers[0].install_service('database')
	Root.servers[1].install_service('analyzer')
	server.fs_root.open('etc/requests/*', true).content = 'apps'
	server.fs_root.open('etc/requests/fake', true).content = 'shoutr\nanalyzer\n'
	
	for i in 20:
		UserHandler.generate_user()
	return 0
