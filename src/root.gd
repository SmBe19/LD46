extends Control

const TICK_PER_SECOND = 10
const LOSE_TICK_WITHOUT_SUCCESS = 100000 # TODO reduce

var request_handler
var servers = []
var dns = {}
var ipaddr = {}
var time_since_tick = 0
var game_tick = 0
var global_uuid = 0
var money = 2048
var money_log = []

var last_successful_request = 0
var game_running = true

func _init():
	randomize()
	add_new_server("shoutr", "10.0.0.1")
	servers[0].disk *= 2

func average(values):
	var sum = 0
	for value in values:
		sum += value
	if len(values) > 0:
		sum /= len(values)
	return sum

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
	return 128 * (max(len(srv1.connections), len(srv2.connections)) + 1)

func connect_servers(srv1, srv2):
	if srv1.connections.has(srv2.ip):
		return 'Connection already exists'
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
	if request.fake_request:
		return
	last_successful_request = game_tick
	var duration = game_tick - request.start_tick
	if duration == 0:
		duration += 1
	var multiplier = (request.type.level+1)*(request.type.level+1)*(request.type.level+1)
	var new_money = multiplier * 256 / duration
	if new_money > 0:
		money_log.append("+$" + str(new_money) + ": " + request.type.full_name + " " + str(request.id))
		money += new_money

func produce_request(request):
	var server = servers[0]
	if len(server.input_queue) >= server.queue_length:
		return false
	if server.receive_request(request):
		request.connect("request_fulfilled", self, "complete_request")
		return true
	return false


func update_displays():
	var happiness = 0.0
	for user in UserHandler.users:
		happiness += user.happiness
	if len(UserHandler.users) > 0:
		happiness /= len(UserHandler.users)
	$"/root/ScnRoot/Angry Users".value = 1 - happiness

	var queue = 0.0
	for server in servers:
		queue += float(len(server.input_queue)) / server.queue_length
	queue /= len(servers)
	$"/root/ScnRoot/Queue".value = queue

func tick():
	game_tick += 1
	for user in UserHandler.users:
		user.tick()
	for server in servers:
		server.tick()
	for server in servers:
		server.process_incoming()
	if game_tick - last_successful_request > LOSE_TICK_WITHOUT_SUCCESS:
		game_running = false
	update_displays()

func _process(delta):
	if not game_running:
		return
	time_since_tick += delta
	while time_since_tick > 1.0/TICK_PER_SECOND:
		tick()
		time_since_tick -= 1.0/TICK_PER_SECOND
