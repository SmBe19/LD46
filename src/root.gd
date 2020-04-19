extends Control

const TICK_PER_SECOND = 10

var request_handler
var servers = []
var dns = {}
var ipaddr = {}
var time_since_tick = 0
var game_tick = 0
var global_uuid = 0
var money = 20480
var money_log = []

func _init():
	add_new_server("shoutr", "10.0.0.1")

func random_ip(prefix):
	if not prefix:
		prefix = randi()%256
	while true:
		var ip = str(prefix) + "." + str(randi()%256) + "." + str(randi()%256) + "." + str(randi()%256)
		if not ipaddr.has(ip):
			return ip

func buy_something(price, what):
	if money < price:
		return 'Not enough money ($' + str(price) + ' required)'
	money_log.append("-$" + str(price) + ": " + what)
	money -= price
	return ''

func new_server_price():
	return 1024

func add_new_server(name, ip):
	var res = buy_something(new_server_price(), 'Server ' + name)
	if res:
		return res
	if dns.has(name) or ipaddr.has(ip):
		return 'Name or IP already in use'
	var new_server = Server.new(name, ip)
	servers.append(new_server)
	dns[name] = new_server
	ipaddr[ip] = new_server
	return ''

func new_connection_price(srv1, srv2):
	return 32 * (max(len(srv1.connections), len(srv2.connections)) + 1)

func connect_servers(srv1, srv2):
	var res = buy_something(new_connection_price(srv1, srv2), 'Connection ' + srv1.server_name + ' <-> ' + srv2.server_name)
	if res:
		return res
	srv1.connections[srv2.ip] = srv2
	srv2.connections[srv1.ip] = srv1
	srv1.update_fs()
	srv2.update_fs()
	return ''

func resolve_name(name):
	if dns.has(name):
		return dns[name].ip
	return name

func resolve_ip(ip):
	if ipaddr.has(ip):
		return ipaddr[ip]
	return null

func get_uuid():
	global_uuid += 1
	return global_uuid

func complete_request(request):
	var duration = game_tick - request.start_tick
	if duration == 0:
		duration += 1
	var multiplier = (request.type.level+1)*(request.type.level+1)
	var new_money = multiplier * 256 / duration
	if new_money > 0:
		money_log.append("+$" + str(new_money) + ": " + request.type.full_name + " " + str(request.id))
		money += new_money

func generate_request(server):
	if len(server.input_queue) >= server.queue_length:
		return
	var difficulty = 0
	var max_difficulty = min(3, game_tick / 1000)
	difficulty = randi() % (max_difficulty + 1)
	var type = RequestHandler.generate_request(difficulty)
	var uuid = get_uuid()
	var ip = random_ip(randi()%100 + 100)
	var request = Request.new(uuid, uuid, ip, type)
	request.connect("request_fulfilled", self, "complete_request")
	server.input_queue.append(request)

func tick():
	game_tick += 1
	if game_tick % 10 == 0:
		generate_request(servers[0])
	for server in servers:
		server.tick()
	for server in servers:
		server.process_incoming()

func _process(delta):
	time_since_tick += delta
	while time_since_tick > 1.0/TICK_PER_SECOND:
		tick()
		time_since_tick -= 1.0/TICK_PER_SECOND
