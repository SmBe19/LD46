extends Control

const TICK_PER_SECOND = 10

var request_handler
var servers = []
var dns = {}
var ipaddr = {}
var time_since_tick = 0
var game_tick = 0
var request_count = 0

func _init():
	add_new_server("shoutr", "10.0.0.1")

func random_ip():
	while true:
		var ip = str(randi()%256) + "." + str(randi()%256) + "." + str(randi()%256) + "." + str(randi()%256)
		if not ipaddr.has(ip):
			return ip

func add_new_server(name, ip):
	if dns.has(name) or ipaddr.has(ip):
		return false
	var new_server = Server.new(name, ip)
	servers.append(new_server)
	dns[name] = new_server
	ipaddr[ip] = new_server
	return true

func connect_servers(srv1, srv2):
	srv1.connections[srv1.ip] = srv1
	srv1.connections[srv2.ip] = srv2

func resolve_name(name):
	if dns.has(name):
		return dns[name].ip
	return name

func resolve_ip(ip):
	if ipaddr.has(ip):
		return ipaddr[ip]
	return null

func complete_request(request):
	print("CONGRATULATIONS FOR COMPLETING REQUEST", request.id)

func generate_request(server):
	if len(server.input_queue) >= server.queue_length:
		print("Queue full, no task for you.")
		return
	var difficulty = 0
	if game_tick > 100:
		difficulty = randi() % 2
	var type = RequestHandler.generate_request(difficulty)
	var request = Request.new(request_count, type)
	request_count += 1
	request.connect("request_fulfilled", self, "complete_request")
	server.input_queue.append(request)
	print("You have a new ", request.type.human_name, " with id ", request.id)

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
