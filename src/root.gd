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

func random_ip():
	while true:
		var ip = str(randi()%256) + "." + str(randi()%256) + "." + str(randi()%256) + "." + str(randi()%256)
		if not ipaddr.has(ip):
			return ip

func add_new_server(name, ip):
	if money < 1024:
		return 'Not enough money ($1024 required)'
	money_log.append("Server " + name + ": -$1024")
	money -= 1024
	if dns.has(name) or ipaddr.has(ip):
		return 'Name or IP already in use'
	var new_server = Server.new(name, ip)
	servers.append(new_server)
	dns[name] = new_server
	ipaddr[ip] = new_server
	return ''

func connect_servers(srv1, srv2):
	if money < 32:
		return 'Not enough money ($32 required)'
	money_log.append("Connection: -$32")
	money -= 32
	srv1.connections[srv2.ip] = srv2
	srv2.connections[srv1.ip] = srv1
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
		money_log.append(request.type.full_name + ": +$" + str(new_money))
		money += new_money

func generate_request(server):
	if len(server.input_queue) >= server.queue_length:
		return
	var difficulty = 0
	if game_tick > 100:
		difficulty = randi() % 2
	var type = RequestHandler.generate_request(difficulty)
	var uuid = get_uuid()
	var request = Request.new(uuid, uuid, type)
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
